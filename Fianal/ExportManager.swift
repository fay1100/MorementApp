//
//  ExportManager.swift
//  Fianal
//
//  Created by Faizah Almalki on 08/11/1445 AH.
//

import Foundation
import SwiftUI
import UIKit

class ExportManager {
    static func exportBoard(view: UIView) {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil)
        UIGraphicsBeginPDFPage()
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndPDFContext()

        let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
