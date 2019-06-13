import Foundation
import Pitchy
import RxSwift
import RxCocoa

enum ExerciseState {
    case ShowingIntro
    case InProgress
    case ShowingOutro
}

enum CurrentQuestionState {
    case PlayingSample
    case Listening
    case NoteTooLow
    case NoteTooHigh
    case Correct
    case Error
}

class ExerciseViewModel {
    private let noteOccurencesNeeded = 4
    private let secondsBeforeNextQuestion: Double = 2
    
    private let instrument: Instrument
    private let audioService: AudioService
    private let exercise: SingleNoteExercise
    
    private let exerciseStateSubject = BehaviorSubject(value: ExerciseState.ShowingIntro)
    private let currentQuestionStateRelay = BehaviorRelay<CurrentQuestionState>(value: .PlayingSample)
    private let disposeBag = DisposeBag()
    
    private var noteToGuess: Note!
    private var potentialNote: Note?
    private var questionsAnswered = 0
    private var potentialNoteOccurences = 0
    private var pitchDetectionSubscription: Disposable?
    
    private var allQuestionsAnswered: Bool {
        return questionsAnswered >= exercise.questions.count
    }
    
    let title: Driver<String>
    let currentQuestionState: Driver<CurrentQuestionState>
    let exerciseState: Driver<ExerciseState>
    
    init(for exercise: SingleNoteExercise, instrument: Instrument, audioService: AudioService) {
        self.instrument = instrument
        self.audioService = audioService
        self.exercise = exercise
        
        noteToGuess = exercise.questions[0].note
        title = Observable.just(exercise.title).asDriver(onErrorJustReturn: "Oooops, an error :(")
        exerciseState = exerciseStateSubject.asDriver(onErrorJustReturn: ExerciseState.ShowingOutro)
        currentQuestionState = currentQuestionStateRelay.skip(1).asDriver(onErrorJustReturn: .Error)
        
        currentQuestionState.asObservable()
            .subscribe(onNext: { [unowned self] state in self.handleStateChange(state) })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit vm")
    }
    
    public func beginExercise() {
        exerciseStateSubject.onNext(.InProgress)
        currentQuestionStateRelay.accept(.PlayingSample)
    }
    
    private func playNote() {
        try! instrument.playNote(note: noteToGuess)
            .subscribe(
                onCompleted: { [unowned self] in self.currentQuestionStateRelay.accept(.Listening) }
            )
            .disposed(by: disposeBag)
    }

    public func replayNote() {
        let statesWithReplayEnabled: [CurrentQuestionState] = [
            .Listening,
            .NoteTooHigh,
            .NoteTooLow
        ]

        guard statesWithReplayEnabled.contains(currentQuestionStateRelay.value) else {
            return
        }

        instrument.stopPlaying()
        stopListening()
        
        try! instrument.playNote(note: noteToGuess)
            .subscribe(onCompleted: { [unowned self] in self.listenForNote() })
            .disposed(by: disposeBag)
    }

    public func stopPlaying() {
        stopListening()
        instrument.stopPlaying()
    }
    
    private func handleStateChange(_ state: CurrentQuestionState) {
        switch state {
            case .PlayingSample:
                playNote()
            case .Listening:
                listenForNote()
            case .Correct:
                setupNextQuestionWithDelay()
            default:
                break
        }
    }

    private func listenForNote() {
        pitchDetectionSubscription = audioService.detectPitch()
            .subscribe(onNext: onPitchDetected)
    }

    private func onPitchDetected(note: Note) {
        if (potentialNote?.string ?? "" == note.string) {
            potentialNoteOccurences += 1
        } else {
            potentialNote = note
            potentialNoteOccurences = 1
        }

        if (potentialNoteOccurences >= noteOccurencesNeeded) {
            checkIfPotentialNoteIsCorrect()
        }
    }

    private func checkIfPotentialNoteIsCorrect() {
        if (potentialNote!.string == noteToGuess.string) {
            currentQuestionStateRelay.accept(.Correct)
            pitchDetectionSubscription?.dispose()
            pitchDetectionSubscription = nil
            return
        }

        if (potentialNote!.frequency > noteToGuess.frequency) {
            currentQuestionStateRelay.accept(.NoteTooHigh)
        } else {
            currentQuestionStateRelay.accept(.NoteTooLow)
        }
    }

    private func stopListening() {
        pitchDetectionSubscription?.dispose()
        pitchDetectionSubscription = nil
    }

    private func setupNextQuestionWithDelay() {
        potentialNote = nil
        potentialNoteOccurences = 0
        questionsAnswered += 1
        
        if (allQuestionsAnswered) {
            goToOutro()
            return
        }
        
        noteToGuess = exercise.questions[questionsAnswered].note
    
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsBeforeNextQuestion) { [unowned self] in
            self.currentQuestionStateRelay.accept(.PlayingSample)
        }
    }
    
    private func goToOutro() {
        exerciseStateSubject.onNext(.ShowingOutro)
    }
}
