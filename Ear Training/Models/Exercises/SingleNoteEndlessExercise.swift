import Foundation
import RxSwift

protocol SingleNoteQuestionGenerator {
    func generateSingleNoteQuestion() -> SingleNoteQuestion
}

class SingleNoteEndlessExercise : Exercise {
    private let questionSubject = PublishSubject<SingleNoteQuestion>()
    
    private let questionGenerator: SingleNoteQuestionGenerator
    
    let title: String
    let description: String
    let questions: Observable<SingleNoteQuestion>
    
    init(title: String, description: String, questionGenerator: SingleNoteQuestionGenerator) {
        self.title = title
        self.description = description
        self.questionGenerator = questionGenerator
        
        questions = questionSubject.asObservable()
    }
    
    func getNextQuestion() {
        questionSubject.onNext(questionGenerator.generateSingleNoteQuestion())
    }
}

