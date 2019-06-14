import Foundation
import RxSwift

class SingleNoteExercise : Exercise {
    let title: String
    let description: String
    let questions: [SingleNoteQuestion]
    
    init(title: String, description: String, questions: [SingleNoteQuestion] ) {
        self.title = title
        self.description = description
        self.questions = questions
    }
    
}
