import Foundation
import Pitchy
import RxSwift
import AVFoundation
import Beethoven

protocol AudioService {
    func playSample(url: URL) throws -> Observable<Unit>
    func detectPitch() -> Observable<Note>
    func stopDetectingPitch()
}

class DefaultAudioService : NSObject, AVAudioPlayerDelegate, AudioService, PitchEngineDelegate {
    private var audioPlaySubject: PublishSubject<Unit>?
    private var audioPlayer: AVAudioPlayer?
    private var pitchEngine: PitchEngine?
    
    private var detectedNoteSubject: PublishSubject<Note>?
    
    func playSample(url: URL) throws -> Observable<Unit> {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlaySubject = PublishSubject<Unit>()
        audioPlayer?.delegate = self
        audioPlayer?.play()
        
        return audioPlaySubject!.asObservable()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlaySubject?.onCompleted()
        audioPlaySubject?.dispose()
        audioPlaySubject = nil
    }
    
    func detectPitch() -> Observable<Note> {
        let config = Config(
            bufferSize: 4096,
            estimationStrategy: .yin
        )
        pitchEngine = PitchEngine(config: config)
        detectedNoteSubject = PublishSubject()
        
        pitchEngine!.delegate = self
        pitchEngine!.start()
        
        return detectedNoteSubject!.asObservable()
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        detectedNoteSubject?.onNext(pitch.note)
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    }
    
    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    }
    
    func stopDetectingPitch() {
        pitchEngine?.stop()
        pitchEngine = nil
        
        detectedNoteSubject?.dispose()
        detectedNoteSubject = nil
    }
}
