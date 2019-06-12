import Foundation
import UIKit
import RxSwift
import RxCocoa

class ExerciseViewController : UIViewController {
    private var presenter: ExercisePresenter!
    private var viewModel: ExerciseViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var lessonTitleLabel: UILabel!
    @IBOutlet weak var beginLessonButton: UIButton!
    @IBOutlet weak var lessonIntroView: UIView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func inject(presenter: ExercisePresenter, viewModel: ExerciseViewModel) {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopPlaying()
    }
    
    private func setupBindings() {
        //UI -> ViewModel
        beginLessonButton.rx.tap
            .subscribe(onNext: viewModel.beginExercise)
            .disposed(by: disposeBag)

        addTapRecognizer().rx.event
            .bind(onNext: {[unowned self] _ in self.viewModel.replayNote()})
            .disposed(by: disposeBag)

        //UI -> Presenter
        closeButton.rx.tap
            .subscribe(onNext: presenter.dismiss)
            .disposed(by: disposeBag)

        //ViewModel -> UI
        viewModel.title
            .drive(lessonTitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.questionState
            .map({[unowned self] state in self.colorFor(questionState: state)})
            .drive(view.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        viewModel.questionState
            .map({[unowned self] state in self.promptTextFor(questionState: state)})
            .drive(promptLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.exerciseHasBegun
            .drive(lessonIntroView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.exerciseHasBegun
            .map(invertBoolean)
            .drive(questionView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit vc")
    }
    
    private func colorFor(questionState: QuestionViewModelState) -> UIColor {
        switch questionState {
            case .PlayingSample: return UIColor.green
            case .Listening: return UIColor.init(red: 0.5, green: 0.5, blue: 0.7, alpha: 1)
            case .NoteTooLow: return UIColor.red
            case .NoteTooHigh: return UIColor.orange
            case .Correct: return UIColor.magenta
            case .Error: return UIColor.black
        }
    }
    
    private func promptTextFor(questionState: QuestionViewModelState) -> String {
        switch questionState {
            case .PlayingSample: return "Listen!"
            case .Listening: return "Play the same note!"
            case .NoteTooLow: return "Too low :("
            case .NoteTooHigh: return "Too high :("
            case .Correct: return "Fooking right"
            case .Error: return "Fuck this shit, i got an error"
        }
    }
    
    private func addTapRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)
        return tapRecognizer
    }
}
