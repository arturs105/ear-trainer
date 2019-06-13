import Foundation
import UIKit
import RxSwift

class ChooseInstrumentViewController : UITableViewController {
    private var presenter: ChooseInstrumentPresenter!
    private var viewModel: ChooseInstrumentViewModel!
    
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "Fuck2"
    private var instruments: [Instrument] = []
    
    func inject(presenter: ChooseInstrumentPresenter, viewModel: ChooseInstrumentViewModel) {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instruments = viewModel.instruments
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instruments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel?.text = instruments[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instrument = instruments[indexPath.row]
        viewModel.changeActiveInstrument(instrument)
        presenter.dismiss()
    }
}
