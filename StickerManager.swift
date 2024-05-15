import Foundation
import CloudKit
import UIKit



class StickerManager {
    static let shared = StickerManager()
    private let publicDatabase = CKContainer(identifier: "iCloud.MorementCloud").publicCloudDatabase
    
    private var updateWorkItem: DispatchWorkItem?
    private let updateQueue = DispatchQueue(label: "com.example.StickerUpdateQueue")
    private let imageCache = NSCache<NSString, UIImage>()  // Cache for storing images
    
    func saveStickerBatch(_ sticker: Sticker, boardID: String, completion: @escaping (Result<Sticker, Error>) -> Void) {
        updateWorkItem?.cancel()
        
        updateWorkItem = DispatchWorkItem { [weak self] in
            self?.saveStickerToCloud(sticker, boardID: boardID, completion: completion)
        }
        
        if let workItem = updateWorkItem {
            updateQueue.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func saveStickerToCloud(_ sticker: Sticker, boardID: String, completion: @escaping (Result<Sticker, Error>) -> Void) {
        if let recordID = sticker.recordID {
            publicDatabase.fetch(withRecordID: recordID) { [weak self] fetchedRecord, error in
                guard let self = self else { return }
                
                if let existingRecord = fetchedRecord {
                    self.updateStickerRecord(existingRecord, with: sticker, boardID: boardID, completion: completion)
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        } else {
            let newRecord = CKRecord(recordType: "Sticker")
            updateStickerRecord(newRecord, with: sticker, boardID: boardID, completion: completion)
        }
    }
    
    private func updateStickerRecord(_ record: CKRecord, with sticker: Sticker, boardID: String, completion: @escaping (Result<Sticker, Error>) -> Void) {
        record["positionX"] = Double(sticker.position.x)
        record["positionY"] = Double(sticker.position.y)
        record["scale"] = Double(sticker.scale)
        record["boardID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none)
        
        // Save image to temporary location
        record["image"] = CKAsset(fileURL: saveImageToTemporaryLocation(sticker.image))
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        modifyOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            DispatchQueue.main.async {
                if let savedRecord = savedRecords?.first {
                    var savedSticker = sticker
                    savedSticker.recordID = savedRecord.recordID
                    completion(.success(savedSticker))
                } else if let error = error {
                    if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                        self.publicDatabase.fetch(withRecordID: record.recordID) { fetchedRecord, fetchError in
                            if let fetchedRecord = fetchedRecord {
                                self.updateStickerRecord(fetchedRecord, with: sticker, boardID: boardID, completion: completion)
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
    
    func fetchStickers(forBoardID boardID: String, completion: @escaping (Result<[Sticker], Error>) -> Void) {
        let predicate = NSPredicate(format: "boardID == %@", CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none))
        let query = CKQuery(recordType: "Sticker", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let records = records {
                    let stickers = records.map { record in
                        Sticker(
                            id: UUID(),  // Generate a new UUID
                            image: self.loadImage(from: record["image"] as? CKAsset),
                            position: CGPoint(x: record["positionX"] as? Double ?? 0.0, y: record["positionY"] as? Double ?? 0.0),
                            scale: CGFloat(record["scale"] as? Double ?? 1.0),
                            recordID: record.recordID
                        )
                    }
                    completion(.success(stickers))
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
}
