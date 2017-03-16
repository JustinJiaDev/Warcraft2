import AVFoundation

class GameSound {

    static let current = GameSound()

    enum SoundName: String {
        case blacksmith
        case tree1
        case tree2
        case tree3
        case tree4
        case bowfire
        case bowhit
        case acknowledge1
        case acknowledge2
        case acknowledge3
        case acknowledge4
        case annoyed1
        case annoyed2
        case annoyed3
        case annoyed4
        case death
        case ready
        case workCompleted = "work-completed"
    }

    init() {
        create("buildings", "blacksmith")
        create("misc", "tree1")
        create("misc", "tree2")
        create("misc", "tree3")
        create("misc", "tree4")
        create("misc", "bowfire")
        create("misc", "bowhit")
        create("basic", "acknowledge1")
        create("basic", "acknowledge2")
        create("basic", "acknowledge3")
        create("basic", "acknowledge4")
        create("basic", "annoyed1")
        create("basic", "annoyed2")
        create("basic", "annoyed3")
        create("basic", "annoyed4")
        create("basic", "death")
        create("basic", "ready")
        create("basic", "work-completed")
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
