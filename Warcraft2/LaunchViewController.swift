import UIKit
import AudioToolbox

class LaunchViewController: UIViewController {
    override func viewDidLoad() {
        do {
            PlayerAsset.updateFrequency = 40
            AssetRenderer.updateFrequency = 40

            AssetDecoratedMap.loadMaps(from: try FileDataContainer(url: url("map")))
            PlayerAssetType.loadTypes(from: try FileDataContainer(url: url("res")))
            PlayerUpgrade.loadUpgrades(from: try FileDataContainer(url: url("upg")))

            BasicCapabilities.registrant.register()
            BuildCapabilities.registrant.register()
            BuildingUpgradeCapabilities.registrant.register()
            TrainCapabilities.registrant.register()
            UnitUpgradeCapabilities.registrant.register()

            GameSound.current.play(.blacksmith)
        } catch {
            printError(error.localizedDescription)
            present(UIAlertController(title: "Game Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
