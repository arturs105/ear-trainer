import Foundation
import RxSwift
import Pitchy

protocol Instrument {
    var name: String { get }
    
    func playNote(note: Note) throws -> Observable<Unit>
    func stopPlaying()
    
    static var sharedInstance: Instrument { get }
}
