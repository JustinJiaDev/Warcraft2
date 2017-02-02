import Foundation

enum DebugLevel {
    case low, normal, high
}

func printDebug(_ message: String, level: DebugLevel = .normal) {
    fatalError("not implemented")
}

func openDebug() {
    fatalError("not implemented")
}

func printError(_ message: String, level: DebugLevel = .normal) {
    print("[ERROR]: \(message)")
}

class Debug {

    init(debug: Debug) {
    }

    static func debugLevel() {
        fatalError("not implemented")
    }
}
