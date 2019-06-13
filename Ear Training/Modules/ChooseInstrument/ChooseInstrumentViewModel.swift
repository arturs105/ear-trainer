import Foundation

class ChooseInstrumentViewModel {
    private var instrumentService: InstrumentService
    
    let instruments: [Instrument]
    
    init(instrumentService: InstrumentService) {
        self.instrumentService = instrumentService
        
        instruments = instrumentService.availableInstruments
    }
    
    func changeActiveInstrument(_ instrument: Instrument) {
        instrumentService.currentlySelectedInstrument = instrument
    }
}
