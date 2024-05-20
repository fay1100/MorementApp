import Foundation
import UIKit
import CloudKit
import SwiftUI

class BoardManager {
    static let shared = BoardManager()
    private let publicDatabase = CKContainer(identifier: "iCloud.MorementCloud").publicCloudDatabase
    private var cache = NSCache<NSString, CKRecord>()  // Cache for storing boards
    
    func generateUniqueID(completion: @escaping (Result<String, Error>) -> Void) {
        func generateRandomID() -> String {
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            let numbers = "0123456789"
            
            let uniqueID = (0..<5).compactMap { _ in letters.randomElement() }
            + (0..<5).compactMap { _ in numbers.randomElement() }
            return String(uniqueID.shuffled())
        }
        
        func checkID(_ id: String) {
            let predicate = NSPredicate(format: "boardID == %@", id)
            let query = CKQuery(recordType: "Board", predicate: predicate)
            publicDatabase.perform(query, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let records = records, !records.isEmpty {
                        checkID(generateRandomID())  // Generate a new ID if the current one is in use
                    } else {
                        completion(.success(id))
                    }
                }
            }
        }
        
        checkID(generateRandomID())
    }
    
    func createBoard(title: String, image: UIImage?, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let imageAsset = image.flatMap { createImageAsset(from: $0) }
        generateUniqueID { result in
            switch result {
            case .success(let uniqueID):
                UserProfileManager.shared.fetchUserProfile { result in
                    switch result {
                    case .success(let nickname):
                        guard let nickname = nickname else {
                            completion(.failure(NSError(domain: "BoardManagerError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                            return
                        }
                        self.createBoardRecord(uniqueID: uniqueID, title: title, ownerNickname: nickname, imageAsset: imageAsset) { result in
                            switch result {
                            case .success(let record):
                                // Adding delay before attempting to fetch the board
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    completion(.success(record))
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    private func createBoardRecord(uniqueID: String, title: String, ownerNickname: String, imageAsset: CKAsset?, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let boardRecord = CKRecord(recordType: "Board")
        boardRecord["boardID"] = uniqueID
        boardRecord["title"] = title
        boardRecord["owner"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: ownerNickname), action: .none)
        boardRecord["isAcceptingMembers"] = NSNumber(value: true)
        boardRecord["boardCreationDate"] = Date()
        
        if let asset = imageAsset {
            boardRecord["image"] = asset
        }
        
        publicDatabase.save(boardRecord) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let record = record {
                    completion(.success(record))
                } else {
                    completion(.failure(NSError(domain: "BoardManagerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
                }
            }
        }
    }
    
    
    func createImageAsset(from image: UIImage) -> CKAsset? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".jpg")
        
        do {
            try data.write(to: fileURL)
            let asset = CKAsset(fileURL: fileURL)
            return asset
        } catch {
            print("Error writing image to disk: \(error)")
            return nil
        }
    }
    
    func deleteTemporaryFile(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting temporary file: \(error)")
        }
    }
    
    func fetchBoards(completion: @escaping (Result<[(CKRecord, UIImage?)], Error>) -> Void) {
        UserProfileManager.shared.fetchUserProfile { result in
            switch result {
            case .success(let nickname):
                guard let nickname = nickname else {
                    completion(.failure(NSError(domain: "BoardManagerError", code: 1004, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                    return
                }
                let predicate = NSPredicate(format: "owner == %@", CKRecord.Reference(recordID: CKRecord.ID(recordName: nickname), action: .none))
                let query = CKQuery(recordType: "Board", predicate: predicate)
                
                self.publicDatabase.perform(query, inZoneWith: nil) { records, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else if let records = records, !records.isEmpty {
                            let boardsWithImages = records.compactMap { record -> (CKRecord, UIImage?)? in
                                let imageAsset = record["image"] as? CKAsset
                                var image: UIImage? = nil
                                if let fileURL = imageAsset?.fileURL {
                                    image = UIImage(contentsOfFile: fileURL.path)
                                }
                                return (record, image)
                            }
                            completion(.success(boardsWithImages))
                        } else {
                            completion(.failure(NSError(domain: "BoardManagerError", code: 1005, userInfo: [NSLocalizedDescriptionKey: "No boards found"])))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBoardsForCurrentUser(completion: @escaping (Result<[(CKRecord, UIImage?)], Error>) -> Void) {
        UserProfileManager.shared.fetchUserProfile { result in
            switch result {
            case .success(let nickname):
                guard let nickname = nickname else {
                    completion(.failure(NSError(domain: "BoardManagerError", code: 1004, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                    return
                }
                let memberReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: nickname), action: .none)
                let predicate = NSPredicate(format: "ANY members == %@", memberReference)
                let query = CKQuery(recordType: "Board", predicate: predicate)
                
                self.publicDatabase.perform(query, inZoneWith: nil) { records, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else if let records = records, !records.isEmpty {
                            let boardDetails = records.compactMap { record -> (CKRecord, UIImage?)? in
                                if let imageAsset = record["image"] as? CKAsset, let fileURL = imageAsset.fileURL {
                                    let image = UIImage(contentsOfFile: fileURL.path)
                                    return (record, image)
                                }
                                return (record, nil)
                            }
                            completion(.success(boardDetails))
                        } else {
                            completion(.failure(NSError(domain: "BoardManagerError", code: 1005, userInfo: [NSLocalizedDescriptionKey: "No boards found"])))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBoardByBoardID(_ boardID: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
          let trimmedBoardID = boardID.trimmingCharacters(in: .whitespacesAndNewlines)
          print("Fetching board with ID: \(trimmedBoardID)")

          let predicate = NSPredicate(format: "boardID == %@", trimmedBoardID)
          let query = CKQuery(recordType: "Board", predicate: predicate)

          publicDatabase.perform(query, inZoneWith: nil) { records, error in
              DispatchQueue.main.async {
                  if let error = error {
                      print("Error during fetch: \(error.localizedDescription)")
                      completion(.failure(error))
                  } else if let records = records, !records.isEmpty {
                      let record = records.first!
                      completion(.success(record))
                  } else {
                      print("Board not found with ID: \(trimmedBoardID)")
                      completion(.failure(NSError(domain: "BoardManagerError", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Board not found"])))
                  }
              }
          }
      }
 




    func addMemberToBoard(memberNickname: String, boardID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let boardRecordID = CKRecord.ID(recordName: boardID)
        publicDatabase.fetch(withRecordID: boardRecordID) { [weak self] record, error in
            guard let self = self, let boardRecord = record else {
                completion(.failure(error ?? NSError(domain: "BoardManagerError", code: 1008, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch board"])))
                return
            }
            
            if let ownerRef = boardRecord["owner"] as? CKRecord.Reference, ownerRef.recordID.recordName == memberNickname {
                completion(.success(()))
                return
            }
            
            let memberReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: memberNickname), action: .none)
            var members = boardRecord["members"] as? [CKRecord.Reference] ?? []
            
            if !members.contains(where: { $0.recordID.recordName == memberNickname }) {
                members.append(memberReference)
                boardRecord["members"] = members
                
                let modifyOperation = CKModifyRecordsOperation(recordsToSave: [boardRecord], recordIDsToDelete: nil)
                modifyOperation.savePolicy = .changedKeys
                modifyOperation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                self.publicDatabase.add(modifyOperation)
            } else {
                completion(.success(()))
            }
        }
    }
    
    func handleBoardDeletion(boardID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchBoardByBoardID(boardID) { [weak self] result in
            switch result {
            case .success(let board):
                guard let self = self else { return }
                UserProfileManager.shared.fetchUserProfile { userProfileResult in
                    switch userProfileResult {
                    case .success(let nickname):
                        if let ownerRef = board["owner"] as? CKRecord.Reference, ownerRef.recordID.recordName == nickname {
                            self.deleteBoard(board: board, completion: completion)
                        } else if var members = board["members"] as? [CKRecord.Reference],
                                  members.contains(where: { $0.recordID.recordName == nickname }) {
                            members.removeAll(where: { $0.recordID.recordName == nickname })
                            board["members"] = members
                            self.publicDatabase.save(board, completionHandler: { _, error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(()))
                                }
                            })
                        } else {
                            completion(.failure(NSError(domain: "BoardManagerError", code: 1009, userInfo: [NSLocalizedDescriptionKey: "You do not have permission to delete this board"])))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func deleteBoard(board: CKRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        publicDatabase.delete(withRecordID: board.recordID) { recordID, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateBoardAcceptance(boardID: String, isAcceptingMembers: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchBoardByBoardID(boardID) { [weak self] result in
            switch result {
            case .success(let board):
                board["isAcceptingMembers"] = NSNumber(value: isAcceptingMembers ? 1 : 0)
                self?.publicDatabase.save(board) { _, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBoardAcceptance(boardID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchBoardByBoardID(boardID) { result in
            switch result {
            case .success(let board):
                if let isAccepting = board["isAcceptingMembers"] as? NSNumber, isAccepting.intValue == 1 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func timeRemaining(from creationDate: Date) -> TimeInterval {
        let now = Date()
        let timeElapsed = now.timeIntervalSince(creationDate)
        let timeRemaining = (24 * 60 * 60) - timeElapsed
        return max(timeRemaining, 0)
    }
    
    func saveStickyNote(_ stickyNote: StickyNote, boardID: String, completion: @escaping (Result<StickyNote, Error>) -> Void) {
        StickyNoteManager.shared.saveStickyNoteBatch(stickyNote, boardID: boardID, completion: completion)
    }
    
    func fetchStickyNotes(forBoardID boardID: String, completion: @escaping (Result<[StickyNote], Error>) -> Void) {
        StickyNoteManager.shared.fetchStickyNotes(forBoardID: boardID, completion: completion)
    }
}
