import Foundation
import MusicTheorySwift
import Pitchy

class ScaleQuestionGenerator : SingleNoteQuestionGenerator {
    let scale: Scale
    
    init(for scale: Scale) {
        self.scale = scale
    }
    
    func generateSingleNoteQuestion() -> SingleNoteQuestion {
        let randomPitchFromScale = scale.pitches(octave: 3).randomElement()!
        let frequencyAsDouble = Double(randomPitchFromScale.frequency)
        let note = try! Note(frequency: frequencyAsDouble)
        return SingleNoteQuestion(note: note)
    }
}
