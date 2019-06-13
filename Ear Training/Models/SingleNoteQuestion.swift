import Foundation
import Pitchy

class SingleNoteQuestion {
    let note: Note
    let state: QuestionState = .Unanswered
    
    init(note: Note) {
        self.note = note
    }
}
