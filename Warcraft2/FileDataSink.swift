import Foundation

class FileDataSink: DataSink {
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

    func write(data: Data) {
        fileHandle.write(data)
    }

    func container() throws -> DataContainer {
        return try FileDataContainer(url: url.deletingLastPathComponent())
    }
}
