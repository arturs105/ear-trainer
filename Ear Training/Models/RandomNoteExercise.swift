import Foundation
import Pitchy

class RandomNoteExercise : Exercise {
    init(questionCount: Int, minNote: Note, maxNote: Note) throws {
        super.init(
            title: "Random notes between \(minNote.string) and \(maxNote.string)",
            questions: try RandomNoteExercise.generateQuestions(questionCount: questionCount, minNote: minNote, maxNote: maxNote)
        )
    }
    
    private static func generateQuestions(questionCount: Int, minNote: Note, maxNote: Note) throws -> [Question] {
        return try Range(uncheckedBounds: (lower: 0, upper: questionCount))
            .map({_ -> Note in try generateRandomNote(minNote: minNote, maxNote: maxNote)})
            .map({note -> Question in Question(note: note)})
    }
    
    private static func generateRandomNote(minNote: Note, maxNote: Note) throws -> Note {
        let indexRange = ClosedRange<Int>.init(uncheckedBounds: (lower: minNote.index, upper: maxNote.index))
        let randomNoteIndex = Int.random(in: indexRange)
        return try Note(index: randomNoteIndex)
    }
}
