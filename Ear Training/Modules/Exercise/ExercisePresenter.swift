import Foundation
import UIKit

class ExercisePresenter {
    private weak var viewController: ExerciseViewController!
    private let viewModelLocator: ViewModelLocator
    
    private init(_ viewModelLocator: ViewModelLocator) {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, exercise: Exercise, instrument: Instrument) -> ExerciseViewController {
        let presenter = ExercisePresenter(viewModelLocator)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ExerciseViewController") as! ExerciseViewController
        
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getLessonViewModel(for: exercise, and: instrument))
        presenter.viewController = viewController
        
        return viewController
    }
}
