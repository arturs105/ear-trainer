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
    @IBOutlet weak var lessonOutroView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    func inject(presenter: ExercisePresenter, viewModel: ExerciseViewModel) {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopPlaying()
        UIApplication.shared.isIdleTimerDisabled = false
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

        doneButton.rx.tap
            .subscribe(onNext: presenter.dismiss)
            .disposed(by: disposeBag)
        
        //ViewModel -> UI
        viewModel.title
            .drive(lessonTitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.currentQuestionState
            .map(ExerciseViewController.colorFor)
            .drive(view.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        viewModel.currentQuestionState
            .map(ExerciseViewController.promptTextFor)
            .drive(promptLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.exerciseState
            .map(ExerciseViewController.shouldHideIntro)
            .drive(lessonIntroView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.exerciseState
            .map(ExerciseViewController.shouldHideExerciseQuestion)
            .drive(questionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.exerciseState
            .map(ExerciseViewController.shouldHideOutro)
            .drive(lessonOutroView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit vc")
    }
    
    private static func colorFor(questionState: CurrentQuestionState) -> UIColor {
        switch questionState {
            case .PlayingSample: return UIColor.green
            case .Listening: return UIColor.init(red: 0.5, green: 0.5, blue: 0.7, alpha: 1)
            case .NoteTooLow: return UIColor.red
            case .NoteTooHigh: return UIColor.orange
            case .Correct: return UIColor.magenta
            case .Error: return UIColor.black
        }
    }
    
    private static func promptTextFor(questionState: CurrentQuestionState) -> String {
        switch questionState {
            case .PlayingSample: return "Listen!"
            case .Listening: return "Play the same note!"
            case .NoteTooLow: return "Too low :("
            case .NoteTooHigh: return "Too high :("
            case .Correct: return "Fooking right"
            case .Error: return "Fuck this shit, i got an error"
        }
    }
    
    private static func shouldHideIntro(questionState: ExerciseState) -> Bool {
        return questionState != .ShowingIntro
    }
    
    private static func shouldHideExerciseQuestion(questionState: ExerciseState) -> Bool {
        return questionState != .InProgress
    }
    
    private static func shouldHideOutro(questionState: ExerciseState) -> Bool {
        return questionState != .ShowingOutro
    }
    
    private func addTapRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)
        return tapRecognizer
    }
}
