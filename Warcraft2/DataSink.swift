import Foundation

protocol DataSink {
    var url: URL { get }
    var containerURL: URL { get }
    func write(data: Data)
}
