import Foundation

class PeriodicTimeout {
    private var nextDeadline: TimeInterval
    private let timeInterval: TimeInterval

    init(periodMS: Int) {
        // time interval defaults to 1 if provided a number <= 0
        if periodMS <= 0 {
            timeInterval = 1
        } else {
            timeInterval = Double(periodMS) / 1000.0
        }
        nextDeadline = Date().timeIntervalSince1970 + timeInterval
    }

    func milliSecondsUntilDeadline() -> Int {
        let currentTime = Date().timeIntervalSince1970
        var timeDelta: TimeInterval = 0
        while true {
            timeDelta = nextDeadline - currentTime
            if timeDelta > 0 { break }
            nextDeadline += timeInterval
        }
        return Int(timeDelta * 1000)
    }
}
