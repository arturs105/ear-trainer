import Foundation
import Pitchy

class Question {
    let note: Note
    let state: QuestionState = .Unanswered
    
    init(note: Note) {
        self.note = note
    }
}
