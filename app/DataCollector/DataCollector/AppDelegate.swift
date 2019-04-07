//
//  AppDelegate.swift
//  DataCollector
//
//  Created by Adam Guest on 05/04/2019.
//  Copyright © 2019 chamook. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        
        window.rootViewController = vc
        self.window = window
        window.makeKeyAndVisible()
                
        return true
    }

  

}

