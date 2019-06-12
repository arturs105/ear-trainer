import Foundation

class Exercise {
    let title: String
    let questions: [Question]
    
    init(title: String, questions: [Question]) {
        self.title = title
        self.questions = questions
    }
}
