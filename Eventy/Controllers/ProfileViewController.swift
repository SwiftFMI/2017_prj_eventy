//
//  ProfileViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var mainUser: User?
    
    // TODO: when this in not nil load the selected user but not the currently logged in
    var userId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadProfile { [unowned self] in
            if let events = self.mainUser?.eventsIds {
                for id in events {
                    if let indexToReload = cachedEvents.index(where: { $0.id == id }) {
                        self.reloadCell(index: events.index(of: id)!)
                    } else {
                        log.debug("Loading event with id: \(id)")
                        self.loadEvent(id: id) { [unowned self] in
                            log.debug("Loaded event with id: \(id)")
                            self.reloadCell(index: events.index(of: id)!)
                        }
                    }
                }
            }
        }
    }
    
    
    func loadProfile(completion: @escaping () -> Void) {
        guard let t = token?.accessToken else { return }
    
        Alamofire.request(
            URL(string: serverIp + "/userinfo")!,
            method: .get,
            headers: ["access-token" : t])
            .validate()
            .responseString { [unowned self] (response) -> Void in // ATTENTION [unowned self] to prevent reference cycle
                guard response.result.isSuccess else {
                    log.error("Error response: \(String(describing: response.result.error))")
                    completion()
                    return
                }
                
                do {
                    log.debug(response.result.value!)
                    
                    if let json = response.result.value {
                        self.mainUser = try User(json)
                        
                        self.nameLabel.text = self.mainUser!.name
                        
                        
                        let profilePicUrl = URL(string: self.mainUser!.profilePicPath)
                        
                        // load without blocking the UI
                        DispatchQueue.global().async {
                            let imageData: Data = try! Data(contentsOf: profilePicUrl!)
                            DispatchQueue.main.async { [unowned self] in
                                self.profileImage.image = UIImage(data: imageData)
                            }
                        }
                        
                        // add the used to the cache for later use
                        if let user = self.mainUser {
                            cachedUsers = cachedUsers.filter { $0.id != user.id }
                            cachedUsers.append(user)
                        }
                        
                    } else {
                        log.warning("cound not get json")
                    }
                } catch {
                    log.warning("Cound not parse response")
                }
                completion()
        }
    
    }
    
    func loadEvent(id: Int, completion: @escaping () -> Void) {
        
        guard let t = token?.accessToken else { return }
        log.info("will load event with id \(id)")
        Alamofire.request(
            URL(string: serverIp + "/event")!,
            method: .get,
            parameters: ["eventid": "\(id)"],
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
                        let event = try Event(json)
                        
                        cachedEvents = cachedEvents.filter { $0.id != event.id }
                        cachedEvents.append(event)
                        
                        
                    } else {
                        log.warning("cound not get json")
                    }
                } catch {
                    log.warning("Cound not parse response")
                }
                completion()
        }
    }
    
    func reloadCell(index: Int) {
        log.info("Reloading cell id: \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async { [unowned self] in
            if self.lastItemsInSection == (self.mainUser?.eventsIds.count ?? 0) {
                // just reload the cell with the info of the newly loaded event
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                // the section has wrong number of rows -> reload
                self.tableView.reloadSections([0], with: .automatic)
            }
            
        }
    }
    
    // Table view:
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var lastItemsInSection = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        lastItemsInSection = self.mainUser?.eventsIds.count ?? 0
       
        return lastItemsInSection
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        log.info(" cell for row at index path \(indexPath)")
        
        if let t = mainUser {
            let event = cachedEvents.first(where: {$0.id == t.eventsIds[indexPath.row]})
            cell.textLabel?.text = event?.name
            cell.detailTextLabel?.text = event?.location
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

