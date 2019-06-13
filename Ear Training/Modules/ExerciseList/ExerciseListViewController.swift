import UIKit
import Pitchy
import AudioKit

class ExerciseListViewController : UITableViewController {
    private var presenter: ExerciseListPresenter!
    private var viewModel: ExerciseListViewModel!
    
    private let cellIdentifier = "Fuck"
    private var exercises: [Exercise] = []
    
    func inject(presenter: ExerciseListPresenter, viewModel: ExerciseListViewModel) {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exercises = viewModel.exercises
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = exercises[indexPath.row].title
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = exercises[indexPath.row]
        presenter.showExercise(exercise, instrument: viewModel.instrument.value)
    }
}

