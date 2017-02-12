import Foundation

class FileDataSink: DataSink {
    private var url: URL
    private var fileHandle: FileHandle

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
}
