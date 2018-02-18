//
//  ProfileViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var mainUser: User?
    
    // TODO: when this in not nil load the selected user but not the currently logged in
    var userId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProfile { [unowned self] in
            if let events = self.mainUser?.eventsIds {
                // TODO load user events here
                // cache sould be used if possible
                // similar logic is used in TrendingViewController
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

