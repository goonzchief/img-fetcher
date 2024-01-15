import Cocoa

struct UnsplashPhoto: Decodable {
  let urls: [String: URL]
}

class PhotoViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var photoTableView: NSTableView!

  var unsplashPhotos: [UnsplashPhoto] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    let unsplashAccessKey = "YOUR_ACCESS_KEY"
    let apiUrl = "https://api.unsplash.com/photos/random?count=10&client_id=\(unsplashAccessKey)"

    if let url = URL(string: apiUrl) {
      let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
        if let data = data, error == nil {
          let decoder = JSONDecoder()
          self?.unsplashPhotos = try decoder.decode([UnsplashPhoto].self, from: data)

          DispatchQueue.main.async {
            self?.photoTableView.reloadData()
          }
        }
      }

      dataTask.resume()
    }
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return unsplashPhotos.count
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView {
    let cellIdentifier = NSUserInterfaceItemIdentifier("PhotoCell")

    if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
      let unsplashPhoto = unsplashPhotos[row]
      let regularURL = unsplashPhoto.urls["regular"]

      if let regularURL = regularURL, let imageData = try? Data(contentsOf: regularURL) {
        cell.imageView?.image = NSImage(data: imageData)
      }

      return cell
    } else {
      return NSTableCellView()
    }
  }
}
