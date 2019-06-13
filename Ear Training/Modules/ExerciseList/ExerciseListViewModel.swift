import Foundation
import Pitchy
import RxSwift
import RxCocoa

class ExerciseListViewModel {
    let instrument: BehaviorRelay<Instrument>
    var exercises: [Exercise] = []
    
    init(audioService: AudioService) {
        let initialInstrument = AcousticGuitar()
        instrument = BehaviorRelay<Instrument>(value: initialInstrument)
        
        var questions = [SingleNoteQuestion]()
        for i in 1...5 {
            let indexRange = 0...3
            let randomNote = AcousticGuitar.availableNotes[Int.random(in: indexRange)]
            questions.append(SingleNoteQuestion(note: randomNote))
        }
    
        exercises = [
            SingleNoteExercise(title: "5 questions, only F2, G2, A2 B2", description: "Some random notes", questions: questions),
            SingleNoteExercise(title: "Only F2", description: "Only F2", questions: [SingleNoteQuestion(note: try! Note(letter: .F, octave: 2))]),
            SingleNoteEndlessExercise(title: "Endless exercise", description: "Description goes here", questionGenerator: ExerciseListViewModel.getNextQuestion)
        ]
    }
    
    private static func getNextQuestion() -> SingleNoteQuestion {
        return SingleNoteQuestion(note: AcousticGuitar.availableNotes.randomElement()!)
    }
    
}
