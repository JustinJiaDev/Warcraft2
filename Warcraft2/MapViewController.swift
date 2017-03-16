import UIKit

class MapViewController: UITableViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AssetDecoratedMap.all.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "No AI" : "Simple AI"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath)
        cell.textLabel?.text = AssetDecoratedMap.all[indexPath.row].mapName
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AIPlayer.level = indexPath.section
        AssetDecoratedMap.currentMapIndex = indexPath.row
        performSegue(withIdentifier: "GameSegue", sender: self)
    }

    @IBAction func buttonTapped(backButton: UIButton) {
        dismiss(animated: true)
    }
}
