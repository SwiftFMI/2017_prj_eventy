//
//  ViewController.swift
//  Eventy
//
//  Created by Valentin Varbanov on 15.01.18.
//

import UIKit
import Alamofire

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        log.verbose("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        log.verbose("Button tapped")
        authenticate { [unowned self] in
            log.verbose("callback")
            log.info(token?.accessToken ?? "no token")
            if token != nil {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            }
        }
    }
    
    func authenticate(completion: @escaping () -> Void) {
        
        log.verbose("sending authentication request....")
        
        guard let user = usernameTextField.text else { return }
        guard let pass = passwordTextField.text else { return }
        
        Alamofire.request(
            URL(string: serverIp + "/login")!,
            method: .get,
            parameters: ["user": user, "pass": pass])
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
                        token = try Token(json)
                    } else {
                        log.warning("cound not get json")
                    }
                } catch {
                    log.warning("Cound not parse response")
                }
                completion()
        }
    }
    
}

