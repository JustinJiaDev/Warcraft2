import Foundation

protocol DataSink {
    func write(data: Data)
    func container() -> DataContainer?
}
