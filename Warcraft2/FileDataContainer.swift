import Foundation

class FileDataContainer: DataContainer {
    private(set) var url: URL

    init(url: URL) throws {
        self.url = url
    }

    var contentURLs: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []
    }
}
