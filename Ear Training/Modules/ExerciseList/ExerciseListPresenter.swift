import Foundation
import UIKit

class ExerciseListPresenter {
    private weak var viewController: ExerciseListViewController!
    private let viewModelLocator: ViewModelLocator
    
    private init(_ viewModelLocator: ViewModelLocator) {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> ExerciseListViewController {
        let presenter = ExerciseListPresenter(viewModelLocator)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ExerciseListViewController") as! ExerciseListViewController
        
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getLessonListViewModel())
        presenter.viewController = viewController

        return viewController
    }
    
    func showExercise(_ exercise: Exercise, instrument: Instrument) {
        let exerciseViewController = ExercisePresenter.create(with: viewModelLocator, exercise: exercise, instrument: instrument)
        viewController.showDetailViewController(exerciseViewController, sender: nil)
    }
}
