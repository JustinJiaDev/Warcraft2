import Foundation

class LineDataSource {
    private var dataSource: DataSource

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func readLine() -> String? {
        var line = ""
        var data = dataSource.readData(ofLength: 1)
        while data.count > 0 {
            let unicodeScalar = UnicodeScalar(data[0])
            guard unicodeScalar != "\n" else { // reaches end of line
                break
            }
            guard unicodeScalar != "\r" else { // handles \r\n
                continue
            }
            line.append(Character(unicodeScalar))
            data = dataSource.readData(ofLength: 1)
        }
        return line.characters.count > 0 ? line : nil
    }
}
