import Foundation

class FileDataSource: DataSource {
    private(set) var url: URL
    private var fileHandle: FileHandle

    var containerURL: URL {
        return url.deletingLastPathComponent()
    }

    init(url: URL) throws {
        self.url = url
        self.fileHandle = try FileHandle(forReadingFrom: url)
    }

    deinit {
        fileHandle.closeFile()
    }

    func readData(ofLength length: Int) -> Data {
        return fileHandle.readData(ofLength: length)
    }
}
