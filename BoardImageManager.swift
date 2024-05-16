import Foundation
import CloudKit
import UIKit

class BoardImageManager {
    static let shared = BoardImageManager()
    private let publicDatabase = CKContainer(identifier: "iCloud.MorementCloud").publicCloudDatabase
    
    private var updateWorkItem: DispatchWorkItem?
    private let updateQueue = DispatchQueue(label: "com.example.BoardImageUpdateQueue")
    private let imageCache = NSCache<NSString, UIImage>()  // Cache for storing images
    
    func saveBoardImageBatch(_ boardImage: BoardImage, boardID: String, completion: @escaping (Result<BoardImage, Error>) -> Void) {
        updateWorkItem?.cancel()
        
        updateWorkItem = DispatchWorkItem { [weak self] in
            self?.saveBoardImageToCloud(boardImage, boardID: boardID, completion: completion)
        }
        
        if let workItem = updateWorkItem {
            updateQueue.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func saveBoardImageToCloud(_ boardImage: BoardImage, boardID: String, completion: @escaping (Result<BoardImage, Error>) -> Void) {
        if let recordID = boardImage.recordID {
            publicDatabase.fetch(withRecordID: recordID) { [weak self] fetchedRecord, error in
                guard let self = self else { return }
                
                if let existingRecord = fetchedRecord {
                    self.updateBoardImageRecord(existingRecord, with: boardImage, boardID: boardID, completion: completion)
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        } else {
            let newRecord = CKRecord(recordType: "BoardImage")
            updateBoardImageRecord(newRecord, with: boardImage, boardID: boardID, completion: completion)
        }
    }
    
    private func updateBoardImageRecord(_ record: CKRecord, with boardImage: BoardImage, boardID: String, completion: @escaping (Result<BoardImage, Error>) -> Void) {
        record["positionX"] = Double(boardImage.position.x)
        record["positionY"] = Double(boardImage.position.y)
        record["frameWidth"] = Double(boardImage.frameSize.width)
        record["frameHeight"] = Double(boardImage.frameSize.height)
        record["boardID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none)
        
        // Save image to temporary location
        record["image"] = CKAsset(fileURL: saveImageToTemporaryLocation(boardImage.image))
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        modifyOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            DispatchQueue.main.async {
                if let savedRecord = savedRecords?.first {
                    var savedBoardImage = boardImage
                    savedBoardImage.recordID = savedRecord.recordID
                    completion(.success(savedBoardImage))
                } else if let error = error {
                    if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                        self.publicDatabase.fetch(withRecordID: record.recordID) { fetchedRecord, fetchError in
                            if let fetchedRecord = fetchedRecord {
                                self.updateBoardImageRecord(fetchedRecord, with: boardImage, boardID: boardID, completion: completion)
                            } else if let fetchError = fetchError {
                                completion(.failure(fetchError))
                            }
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
        publicDatabase.add(modifyOperation)
    }
    
    private func saveImageToTemporaryLocation(_ image: UIImage) -> URL {
        let data = image.jpegData(compressionQuality: 0.7)  // Reduce the quality to reduce the size
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? data?.write(to: fileURL)
        return fileURL
    }
    func fetchBoardImages(forBoardID boardID: String, completion: @escaping (Result<[BoardImage], Error>) -> Void) {
        let predicate = NSPredicate(format: "boardID == %@", CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none))
        let query = CKQuery(recordType: "BoardImage", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let records = records {
                    let boardImages = records.map { record in
                        BoardImage(
                            image: self.loadImage(from: record["image"] as? CKAsset),
                            position: CGPoint(x: record["positionX"] as? Double ?? 0.0, y: record["positionY"] as? Double ?? 0.0),
                            frameSize: CGSize(width: record["frameWidth"] as? Double ?? 200, height: record["frameHeight"] as? Double ?? 200),
                            recordID: record.recordID
                        )
                    }
                    completion(.success(boardImages))
                } else {
                    completion(.success([]))
                }
            }
        }
    }

    private func loadImage(from asset: CKAsset?) -> UIImage {
        guard let fileURL = asset?.fileURL else { return UIImage() }
        
        // Check if the image is already cached
        if let cachedImage = imageCache.object(forKey: fileURL.path as NSString) {
            return cachedImage
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else { return UIImage() }
        let image = UIImage(data: imageData) ?? UIImage()
        
        // Cache the image
        imageCache.setObject(image, forKey: fileURL.path as NSString)
        
        return image
    }

    func deleteBoardImage(_ boardImage: BoardImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let recordID = boardImage.recordID else {
            completion(.failure(NSError(domain: "InvalidRecordID", code: -1, userInfo: nil)))
            return
        }
        
        publicDatabase.delete(withRecordID: recordID) { recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

struct BoardImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
    var frameSize: CGSize
    var recordID: CKRecord.ID?
}
