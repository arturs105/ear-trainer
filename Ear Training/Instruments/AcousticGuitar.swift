import Foundation
import RxSwift
import Pitchy
import AVFoundation

class AcousticGuitar: NSObject, Instrument, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var finishedPlayingSubject: PublishSubject<Unit>?
    
    let name = "Acoustic Guitar"
    static let availableNotes = [
        try! Note(letter: .F, octave: 2),
        try! Note(letter: .G, octave: 2),
        try! Note(letter: .A, octave: 2),
        try! Note(letter: .B, octave: 2),
    ]
    
    func playNote(note: Note) throws -> Observable<Unit> {
        if audioPlayer?.isPlaying ?? false {
            audioPlayer?.stop()
            audioPlayer = nil

            finishedPlayingSubject?.onCompleted()
            finishedPlayingSubject = nil
        }
        let audioSample = sample(for: note)
        finishedPlayingSubject = PublishSubject<Unit>()
        audioPlayer = try! AVAudioPlayer(contentsOf: audioSample)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        return finishedPlayingSubject!.asObservable()
    }
    
    private func sample(for note: Note) -> URL {
        return Bundle.main.url(forResource: note.string, withExtension: "mp3")!
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishedPlayingSubject?.onCompleted()
    }
}
