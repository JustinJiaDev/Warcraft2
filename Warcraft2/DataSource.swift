import Foundation

protocol DataSource {
    var url: URL { get }
    var containerURL: URL { get }
    func readData(ofLength length: Int) -> Data
}
