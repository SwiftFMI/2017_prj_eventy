//
//  EventViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var eventId: Int? = nil
    var event: Event?
    
    var myTitle: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            navigationBar.title = newValue
            titleLabel.text = newValue
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageTableView: UITableView! {
        didSet {
            imageTableView.delegate = self
            imageTableView.dataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = eventId {
            event = cachedEvents.first(where: { $0.id == id })
        }
        
        myTitle = event?.name ?? ""
        
        locationLabel.text = event?.location
        
        mainImage.loadAsync(fromUrl: event?.imagePaths.first)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        log.verbose("Event with id \(String(describing: eventId))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        // TODO implement image upload
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max((event?.imagePaths.count ?? 0) - 1, 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        
        log.info(" cell for row at index path \(indexPath)")
        
        if let cell = cell as? ImageTableViewCell {
            cell.myImage.loadAsync(fromUrl: event?.imagePaths[indexPath.row + 1])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.width / 2
    }

}


extension UIImageView {
    func loadAsync(fromUrl stringUrl: String?) {
        guard let stringUrl = stringUrl else { return }
        
        if let url = URL(string: stringUrl) {
            DispatchQueue.global().async {
                
                do {
                    let imageData: Data = try Data(contentsOf: url)
                    DispatchQueue.main.async { [unowned self] in
                        self.image = UIImage(data: imageData)
                        log.verbose("Loaded image from url: \(stringUrl)")
                    }
                } catch {
                    log.error("Could not load image from url: \(stringUrl)")
                }
            }
        }
    }
}

