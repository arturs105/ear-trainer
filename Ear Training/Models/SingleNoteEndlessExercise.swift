import Foundation
import RxSwift

class SingleNoteEndlessExercise : Exercise {
    private let questionSubject = PublishSubject<SingleNoteQuestion>()
    
    private let questionGenerator: () -> SingleNoteQuestion
    
    let title: String
    let description: String
    let questions: Observable<SingleNoteQuestion>
    
    init(title: String, description: String, questionGenerator: @escaping () -> SingleNoteQuestion) {
        self.title = title
        self.description = description
        self.questionGenerator = questionGenerator
        
        questions = questionSubject.asObservable()
    }
    
    func getNextQuestion() {
        questionSubject.onNext(questionGenerator())
    }
}
