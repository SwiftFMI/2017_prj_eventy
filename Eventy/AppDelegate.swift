//
//  AppDelegate.swift
//  Eventy
//
//  Created by Valentin Varbanov on 15.01.18.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self
var token: Token?

//let serverIp = "http://10.0.1.203:8080"
let serverIp = "http://localhost:8080"

var cachedEvents = [Event]()
var cachedUsers = [User]()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()
        
        // add the destinations to SwiftyBeaver
        log.addDestination(console)
        
        // Now let’s log!
//        log.verbose("not so important")  // prio 1, VERBOSE in silver
//        log.debug("something to debug")  // prio 2, DEBUG in green
//        log.info("a nice information")   // prio 3, INFO in blue
//        log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
//        log.error("ouch, an error did occur!")  // prio 5, ERROR in red

        log.verbose("Starting up.")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

