import Foundation
import RxSwift
import Pitchy

class AcousticGuitar: Instrument {
    private let audioService: AudioService
    
    let name = "Acoustic Guitar"
    static let availableNotes = [
        try! Note(letter: .F, octave: 2),
        try! Note(letter: .G, octave: 2),
        try! Note(letter: .A, octave: 2),
        try! Note(letter: .B, octave: 2),
    ]
    
    init(audioService: AudioService) {
        self.audioService = audioService
    }
    
    func playNote(note: Note) throws -> Observable<Unit> {
        let audioSample = sample(for: note)
        return try audioService.playSample(url: audioSample)
    }
    
    func sample(for note: Note) -> URL {
        return Bundle.main.url(forResource: note.string, withExtension: "mp3")!
    }   
}
