import Foundation

class ChooseInstrumentViewModel {
    private var instrumentService: InstrumentService
    
    let instruments: [Instrument]
    
    init(instrumentService: InstrumentService) {
        self.instrumentService = instrumentService
        
        instruments = instrumentService.availableInstruments
    }
    
    deinit {
        print ("deinit choose instrument VM")
    }
    
    func changeActiveInstrument(_ instrument: Instrument) {
        instrumentService.currentlySelectedInstrument = instrument
    }
}
