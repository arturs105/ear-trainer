import Foundation
import Pitchy
import RxSwift
import RxCocoa

class ExerciseListViewModel {
    let instrument: BehaviorRelay<Instrument>
    var exercises: [Exercise] = []
    
    init(audioService: AudioService) {
        let initialInstrument = AcousticGuitar(audioService: audioService)
        instrument = BehaviorRelay<Instrument>(value: initialInstrument)
        
        var questions = [Question]()
        for i in 1...10 {
            let indexRange = 0...3
            let randomNote = AcousticGuitar.availableNotes[Int.random(in: indexRange)]
            questions.append(Question(note: randomNote))
        }
    
        exercises = [
            Exercise(title: "Test Exercise", questions: questions)
        ]
    }
    
    
}