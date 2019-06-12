import Foundation

struct AudioSample {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    init(url: String) {
        self.init(url: URL.init(string: url)!)
    }
}
