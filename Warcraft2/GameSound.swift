import Foundation
import AVFoundation

class GameSound {

    static let current = GameSound()

    enum SoundName: String {
        case blacksmith
        case tree = "tree1"
        case goldMine = "gold-mine"
    }

    init() {
        create("buildings", "gold-mine")
        create("buildings", "blacksmith")
        create("misc", "tree1")
    }

    var soundIDs: [String: SystemSoundID] = [:]

    func create(_ category: String, _ name: String) {
        var id: SystemSoundID = 0
        let soundURL = url("snd", category, name.appending(".wav")) as CFURL
        AudioServicesCreateSystemSoundID(soundURL, &id)
        soundIDs[name] = id
    }

    func play(_ name: SoundName) {
        guard let id = soundIDs[name.rawValue] else {
            return
        }
        AudioServicesPlaySystemSound(id)
    }
}
