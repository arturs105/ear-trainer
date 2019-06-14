import Foundation
import UIKit

class ChooseInstrumentPresenter {
    private weak var viewController: ChooseInstrumentViewController!
    private let viewModelLocator: ViewModelLocator
    
    private init(_ viewModelLocator: ViewModelLocator) {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> ChooseInstrumentViewController {
        let presenter = ChooseInstrumentPresenter(viewModelLocator)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChooseInstrumentViewController") as! ChooseInstrumentViewController
        
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getChooseInstrumentViewModel())
        presenter.viewController = viewController
        
        return viewController
    }
    
    deinit {
        print ("deinit choose instrument presenter")
    }
    
    func dismiss() {
        viewController.navigationController?.popViewController(animated: true)
    }
}
