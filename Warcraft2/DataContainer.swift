import Foundation

protocol DataContainer {
    var url: URL { get }
    var contentURLs: [URL] { get }
}
