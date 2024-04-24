//import CloudKit
//import UIKit
//
//let container = CKContainer(identifier: "iCloud.Fa.cloud")
//
//func requestUserDiscoverability() {
//    container.requestApplicationPermission(.userDiscoverability) { status, error in
//        if status == .granted {
//            print("Permission granted")
//            fetchUserDetails()
//        } else {
//            print("Permission not granted: \(String(describing: error))")
//        }
//    }
//}
//func fetchUserDetails() {
//    container.fetchUserRecordID { recordID, error in
//        guard let recordID = recordID, error == nil else {
//            print("Error fetching user record ID: \(String(describing: error))")
//            return
//        }
//
//        container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
//            guard let identity = identity, error == nil else {
//                print("Error discovering user identity: \(String(describing: error))")
//                return
//            }
//
//            let fullName = identity.nameComponents?.formatted() ?? "Unknown User"
//            print("User Name: \(fullName)")
//        }
//    }
//}
//func saveUserImage(image: UIImage) {
//    let publicDatabase = container.publicCloudDatabase
//    let userProfileRecord = CKRecord(recordType: "UserProfile")
//    if let imageData = image.jpegData(compressionQuality: 0.8) {
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tempImage.jpg")
//        try? imageData.write(to: url)
//        let imageAsset = CKAsset(fileURL: url)
//        userProfileRecord["profileImage"] = imageAsset
//
//        publicDatabase.save(userProfileRecord) { record, error in
//            if let error = error {
//                print("Error saving user profile image: \(error)")
//            } else {
//                print("User profile image saved successfully.")
//                // Cleanup temporary file
//                try? FileManager.default.removeItem(at: url)
//            }
//            
//        }
//        
//    }
//}
