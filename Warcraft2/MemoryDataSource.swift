import Foundation

class MemoryDataSource: DataSource {
    private let data: Data
    private var offset: Int

    init(data: Data) {
        self.data = data
        self.offset = 0
    }

    func readData(ofLength length: Int) -> Data {
        let length = max(min(length, data.count - length), 0)
        return data.subdata(in: offset ..< length)
    }
}
