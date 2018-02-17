//
//  UsersTableViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit
import Alamofire

class UsersTableViewController: UITableViewController {
    
    var userIds: [Int]! = nil
    var createdByUserId: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    func loadUser(id: Int, completion: @escaping () -> Void) {
        guard let t = token?.accessToken else { return }
        
        log.info("will load user with id \(id)")
        Alamofire.request(
            URL(string: serverIp + "/user")!,
            method: .get,
            parameters: ["userid": "\(id)"],
            headers: ["access-token": t])
            .validate()
            .responseString { (response) in
                guard response.result.isSuccess else {
                    log.error("Error response: \(String(describing: response.result.error))")
                    completion()
                    return
                }
                
                do {
                    log.debug(response.result.value!)
                    
                    if let json = response.result.value {
                        let user = try User(json)
                        
                        cachedUsers = cachedUsers.filter { $0.id != user.id }
                        cachedUsers.append(user)
                        
                        
                    } else {
                        log.warning("cound not get json")
                    }
                } catch {
                    log.warning("Cound not parse response")
                }
                completion()
        }
    }
    
    func reloadData() {
        for id in userIds {
            if let indexToReload = cachedUsers.index(where: { $0.id == id }) {
                reloadCell(index: indexToReload)
            } else {
                log.debug("Loading user with id: \(id)")
                loadUser(id: id) { [unowned self] in
                    log.debug("Loaded user with id: \(id)")
                    self.reloadCell(index: self.userIds.index(of: id)!)
                }
            }
        }
    }
    
    func reloadCell(index: Int) {
        log.info("Reloading cell id: \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async { [unowned self] in
            // just reload the cell with the info of the newly loaded event
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIds.count
    }
    
    var imagesForUsers = [UIImage]()

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        if let user = cachedUsers.first(where: {$0.id == userIds[indexPath.row]}) {
            cell.textLabel?.text = user.name
            if user.id == createdByUserId {
                cell.detailTextLabel?.text = "(creator)"
            }
            
            if let image = imagesForUsers[safe: indexPath.row] {
                cell.imageView?.image = image
            } else {
                if let url = URL(string: user.profilePicPath) {
                    DispatchQueue.global().async {
                        do {
                            let imageData: Data = try Data(contentsOf: url)
                            DispatchQueue.main.async { [weak self] in
                                guard let img = UIImage(data: imageData) else { return }
                                self?.imagesForUsers.insert(img, at: indexPath.row)
                                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                                log.verbose("Loaded image from url: \(user.profilePicPath)")
                            }
                        } catch {
                            log.error("Could not load image from url: \(user.profilePicPath)")
                        }
                    }
                }
            }
            
            
        }

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
