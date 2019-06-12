import Pitchy
import RxSwift

class ElectricBass: Instrument {
    let audioService: AudioService
    
    let name: String = "Electric Bass"
    
    init(audioService: AudioService) {
        self.audioService = audioService
    }
    
    func playNote(note: Note) throws -> Observable<Unit> {
        return try audioService.playSample(url: sample(for: note))
    }
    
    func sample(for note: Note) -> URL {
        return URL(string: "")!
    }
}
