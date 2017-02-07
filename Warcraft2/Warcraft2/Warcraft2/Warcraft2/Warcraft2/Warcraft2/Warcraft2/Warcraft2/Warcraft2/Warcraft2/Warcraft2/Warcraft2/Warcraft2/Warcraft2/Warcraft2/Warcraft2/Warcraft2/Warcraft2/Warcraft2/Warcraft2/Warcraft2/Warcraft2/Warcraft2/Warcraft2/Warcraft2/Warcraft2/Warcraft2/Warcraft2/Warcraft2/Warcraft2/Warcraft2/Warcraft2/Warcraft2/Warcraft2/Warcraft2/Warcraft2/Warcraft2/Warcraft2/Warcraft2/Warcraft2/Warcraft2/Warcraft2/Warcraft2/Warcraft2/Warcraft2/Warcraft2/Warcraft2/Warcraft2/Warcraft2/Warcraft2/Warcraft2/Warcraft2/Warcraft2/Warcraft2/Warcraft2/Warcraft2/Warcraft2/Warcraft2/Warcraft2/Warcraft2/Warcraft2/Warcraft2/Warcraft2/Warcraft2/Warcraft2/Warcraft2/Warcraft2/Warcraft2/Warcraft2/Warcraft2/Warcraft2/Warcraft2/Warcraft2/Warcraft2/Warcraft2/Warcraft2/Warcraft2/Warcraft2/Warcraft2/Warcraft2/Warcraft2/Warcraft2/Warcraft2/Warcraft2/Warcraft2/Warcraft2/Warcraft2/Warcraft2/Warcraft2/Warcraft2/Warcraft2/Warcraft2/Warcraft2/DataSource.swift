import Foundation

protocol DataSource {
    func readData(ofLength length: Int) -> Data
    func container() -> DataContainer?
}
