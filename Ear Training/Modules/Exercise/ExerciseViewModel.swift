import Foundation
import Pitchy
import RxSwift
import RxCocoa

enum QuestionViewModelState {
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
    
    private let exerciseHasBegunSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>.init(value: false)
    private let exerciseStateRelay = BehaviorRelay<QuestionViewModelState>(value: .PlayingSample)
    
    private var noteToGuess: Note
    private var potentialNote: Note?
    private var potentialNoteOccurences = 0
    private let disposeBag = DisposeBag()
    private var pitchDetectionSubscription: Disposable?
    
    let title: Driver<String>
    let questionState: Driver<QuestionViewModelState>
    let exerciseHasBegun: Driver<Bool>
    let questions: [Question]
    var currentQuestionIndex = 0
    
    init(for exercise: Exercise, instrument: Instrument, audioService: AudioService) {
        self.instrument = instrument
        self.audioService = audioService
    
        questions = exercise.questions
        noteToGuess = questions[0].note
        title = Observable.just(exercise.title).asDriver(onErrorJustReturn: "Oooops, an error :(")
        exerciseHasBegun = exerciseHasBegunSubject.asDriver(onErrorJustReturn: false)
        questionState = exerciseStateRelay.skip(1).asDriver(onErrorJustReturn: .Error)
        
        questionState.asObservable()
            .subscribe(onNext: handleStateChange)
            .disposed(by: disposeBag)
    }
    
    public func beginExercise() {
        exerciseHasBegunSubject.onNext(true)
        exerciseStateRelay.accept(.PlayingSample)
    }
    
    public func replayNote() {
        let statesWithReplayEnabled: [QuestionViewModelState] = [
            .Listening,
            .NoteTooHigh,
            .NoteTooLow
        ]
    
        guard statesWithReplayEnabled.contains(exerciseStateRelay.value) else {
            return
        }
        
        stopListening()
        _ = try! instrument.playNote(note: noteToGuess)
            .subscribe(onCompleted: listenForNote)
    }
    
    private func handleStateChange(state: QuestionViewModelState) {
        switch state {
            case .PlayingSample:
                playNote()
            case .Listening:
                listenForNote()
            case .Correct:
                goToNextQuestion()
            default:
                break
        }
    }
    
    private func playNote() {
        _ = try! instrument.playNote(note: noteToGuess)
            .subscribe(
                onCompleted: { self.exerciseStateRelay.accept(.Listening) }
            )
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
            exerciseStateRelay.accept(.Correct)
            pitchDetectionSubscription?.dispose()
            pitchDetectionSubscription = nil
            return
        }
        
        if (potentialNote!.frequency > noteToGuess.frequency) {
            exerciseStateRelay.accept(.NoteTooHigh)
        } else {
            exerciseStateRelay.accept(.NoteTooLow)
        }
    }
    
    private func stopListening() {
        pitchDetectionSubscription?.dispose()
        pitchDetectionSubscription = nil
    }
    
    private func goToNextQuestion() {
        potentialNote = nil
        potentialNoteOccurences = 0
        currentQuestionIndex += 1
        noteToGuess = questions[currentQuestionIndex].note

        DispatchQueue.main.asyncAfter(deadline: .now() + secondsBeforeNextQuestion) {
            self.exerciseStateRelay.accept(.PlayingSample)
        }
    }
}
