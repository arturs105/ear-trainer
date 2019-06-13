import Foundation

protocol InstrumentService {
    var availableInstruments:[Instrument] { get }
    var currentlySelectedInstrument: Instrument { get set }
}

class DefaultInstrumentService : InstrumentService {
    let availableInstruments = [
        AcousticGuitar.sharedInstance,
        SimpleOscillator.sharedInstance
    ]
    
    var currentlySelectedInstrument: Instrument
    
    init() {
        currentlySelectedInstrument = SimpleOscillator.sharedInstance
    }
}
