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
    
    private let exerciseStateSubject = BehaviorSubject(value: ExerciseState.ShowingIntro)
    private let currentQuestionStateRelay = BehaviorRelay<CurrentQuestionState>(value: .PlayingSample)
    
    private var noteToGuess: Note
    private var potentialNote: Note?
    private var potentialNoteOccurences = 0
    private let disposeBag = DisposeBag()
    private var pitchDetectionSubscription: Disposable?
    
    let title: Driver<String>
    let currentQuestionState: Driver<CurrentQuestionState>
    let exerciseState: Driver<ExerciseState>
    let questions: [Question]
    var currentQuestionIndex = 0
    
    init(for exercise: Exercise, instrument: Instrument, audioService: AudioService) {
        self.instrument = instrument
        self.audioService = audioService
    
        questions = exercise.questions
        noteToGuess = questions[0].note
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
                goToNextQuestionOrOutro()
            default:
                break
        }
    }

    private func playNote() {
        try! instrument.playNote(note: noteToGuess)
            .subscribe(
                onCompleted: { [unowned self] in self.currentQuestionStateRelay.accept(.Listening) }
            )
            .disposed(by: disposeBag)
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

    private func goToNextQuestionOrOutro() {
        potentialNote = nil
        potentialNoteOccurences = 0
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questions.count {
            goToOutro()
            return
        }
        
        noteToGuess = questions[currentQuestionIndex].note
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsBeforeNextQuestion) {
            self.currentQuestionStateRelay.accept(.PlayingSample)
        }
    }
    
    private func goToOutro() {
        exerciseStateSubject.onNext(.ShowingOutro)
    }
}
