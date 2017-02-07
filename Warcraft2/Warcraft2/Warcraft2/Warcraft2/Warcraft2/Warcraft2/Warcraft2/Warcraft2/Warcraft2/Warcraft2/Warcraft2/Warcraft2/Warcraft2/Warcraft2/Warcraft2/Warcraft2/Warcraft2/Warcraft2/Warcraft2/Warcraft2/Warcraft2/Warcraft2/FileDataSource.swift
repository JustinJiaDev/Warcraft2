import Foundation

class FileDataSource: DataSource {
    private var url: URL
    private var fileHandle: FileHandle

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

    func container() -> DataContainer? {
        fatalError("This method is not yet implemented.")
    }
}
