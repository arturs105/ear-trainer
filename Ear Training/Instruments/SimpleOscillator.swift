import Foundation
import RxSwift
import Pitchy
import AudioKit

class SimpleOscillator: Instrument {
    private let oscillator: AKOscillator
    private var finishedPlayingSubject: PublishSubject<Unit>?
    
    let name = "Simple Oscillator"
    
    private static var simpleOscillatorInstance: SimpleOscillator?
    static var sharedInstance: Instrument {
        if simpleOscillatorInstance == nil {
            simpleOscillatorInstance = SimpleOscillator()
        }
        
        return simpleOscillatorInstance!
    }
    
    private init() {
        oscillator = AKOscillator()
        oscillator.rampDuration = 0
    
        AudioKit.output = oscillator
        try! AudioKit.start()
    }
    
    func playNote(note: Note) throws -> Observable<Unit> {
        oscillator.stop()
        oscillator.frequency = note.frequency
        oscillator.start()
        
        finishedPlayingSubject = PublishSubject()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[unowned self] in
            self.oscillator.stop()
            self.finishedPlayingSubject?.onCompleted()
            self.finishedPlayingSubject = nil
        }
        
        return finishedPlayingSubject!.asObservable()
    }
    
    func stopPlaying() {
        oscillator.stop()
    }
    
    
}
