//
//  TrendingTableViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit
import Alamofire

class TrendingTableViewController: UITableViewController {
    
    var trending: Trending?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        loadTrending { [unowned self] in
            self.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTrending(completion: @escaping () -> Void) {
        guard let t = token?.accessToken else { return }
        
        Alamofire.request(
            URL(string: serverIp + "/trending")!,
            method: .get,
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
                        self.trending = try Trending(json)
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
    
    func reloadData() {
        
        guard let ids = trending?.ids else { return }
        for  id in ids {
            if let indexToReload = cachedEvents.index(where: { $0.id == id }) {
                reloadCell(index: indexToReload)
            } else {
                log.debug("Loading event with id: \(id)")
                loadEvent(id: id) { [unowned self] in
                    log.debug("Loaded event with id: \(id)")
                    self.reloadCell(index: ids.index(of: id)!)
                }
            }
        }
    }
    
    func reloadCell(index: Int) {
        log.info("Reloading cell id: \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async { [unowned self] in
            if self.lastItemsInSection == (self.trending?.ids.count ?? 0) {
                // just reload the cell with the info of the newly loaded event
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                // the section has wrong number of rows -> reload
                self.tableView.reloadSections([0], with: .automatic)
            }
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var lastItemsInSection = 0

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        lastItemsInSection = trending?.ids.count ?? 0
        
        return lastItemsInSection
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        log.info(" cell for row at index path \(indexPath)")
        // Configure the cell...
        
        
        if let t = trending {
            let event = cachedEvents.first(where: {$0.id == t.ids[indexPath.row]})
            cell.textLabel?.text = event?.name
            cell.detailTextLabel?.text = event?.location
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let indexPath = tableView.indexPathForSelectedRow{
            let eventId = trending?.ids[indexPath.row]
            if let eventVC = segue.destination as? EventViewController {
                eventVC.eventId = eventId
            }
        }
    }
}
