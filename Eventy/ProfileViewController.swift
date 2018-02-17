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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProfile {}
    }
    
    
    func loadProfile(completion: @escaping () -> Void) {
        guard let t = token?.accessToken else { return }
    
        Alamofire.request(
            URL(string: serverIp + "/userinfo")!,
            method: .get,
            headers: ["access-token" : t])
            .validate()
            .responseString { (response) -> Void in
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
                        let imageData: Data = try! Data(contentsOf: profilePicUrl!)
                        self.profileImage.image = UIImage(data: imageData)
                        
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

