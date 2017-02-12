import Foundation

class FileDataContainer: DataContainer {
    private var url: URL

    init(url: URL) throws {
        self.url = url
    }

    var urls: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)) ?? []
    }
}
