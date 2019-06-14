import Foundation
import MusicTheorySwift
import Pitchy
import RxSwift
import RxCocoa
import AudioKit

class ExerciseListViewModel {
    let instrument: BehaviorRelay<Instrument>
    var exercises: [Exercise] = []
    
    init(audioService: AudioService) {
        let initialInstrument = AcousticGuitar.sharedInstance
        instrument = BehaviorRelay<Instrument>(value: initialInstrument)
        
        var questions = [SingleNoteQuestion]()
        for _ in 1...5 {
            let indexRange = 0...3
            let randomNote = AcousticGuitar.availableNotes[Int.random(in: indexRange)]
            questions.append(SingleNoteQuestion(note: randomNote))
        }
    
        let keys = [
            Key(type: .c),
            Key(type: .c, accidental: .sharp), //Swift ftw
            Key(type: .d),
            Key(type: .d, accidental: .sharp),
            Key(type: .e),
            Key(type: .f),
            Key(type: .f, accidental: .sharp),
            Key(type: .g),
            Key(type: .g, accidental: .sharp),
            Key(type: .a),
            Key(type: .a, accidental: .sharp),
            Key(type: .b),
        ]
        
        let allMajorScaleEndlessExercises = keys.map({key in Scale(type: .major, key: key)})
            .map({scale in ScaleQuestionGenerator(for: scale)})
            .map({questionGenerator in SingleNoteEndlessExercise(title: questionGenerator.scale.description, description: "Description", questionGenerator: questionGenerator)})
        
        exercises = [
            SingleNoteExercise(title: "5 questions, only F2, G2, A2 B2", description: "Some random notes", questions: questions),
            SingleNoteExercise(title: "Only F2", description: "Only F2", questions: [SingleNoteQuestion(note: try! Note(letter: .F, octave: 2))]),
            SingleNoteExercise(title: "Only B2", description: "Only F2", questions: [SingleNoteQuestion(note: try! Note(letter: .B, octave: 2))]),
        ]
        
        exercises.append(contentsOf: allMajorScaleEndlessExercises)
    }
}
