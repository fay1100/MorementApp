//
//  FianalApp.swift
//  Fianal
//
//  Created by Faizah Almalki on 29/09/1445 AH.
//

import SwiftUI

@main
struct FianalApp: App {
    @State private var inputImage: UIImage? = nil
    @State private var stickerImageName: String = "defaultImageName"  // Default image name for stickers
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
      }
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
    
}
 
