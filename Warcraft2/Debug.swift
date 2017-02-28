import Foundation

enum DebugLevel {
    case low, normal, high
}

func printDebug(_ message: String, level: DebugLevel = .normal) {
    print("[debug-\(level)]: \(message)")
}

func printError(_ message: String, level: DebugLevel = .normal) {
    print("[error-\(level)]: \(message)")
}

func printFatal(_ message: String) -> Never {
    print("[fatal-\(DebugLevel.high)]: \(message)")
    fatalError()
}
