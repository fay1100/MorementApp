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

    var body: some Scene {
        WindowGroup {
            // Assuming BoardView requires a parameter named 'addSticker' rather than 'sticker'
            BoardView(inputImage: $inputImage, addSticker: Sticker(imageName: stickerImageName))
        }
    }
}
