import Foundation
import UIKit
import CloudKit
import SwiftUI

extension Color {
    // تحويل Color إلى رمز سداسي
    func toHex() -> String {
        let components = UIColor(self).cgColor.components!
        let r: CGFloat = components[0]
        let g: CGFloat = components.count > 1 ? components[1] : r
        let b: CGFloat = components.count > 2 ? components[2] : r
        return String(format: "#%02lX%02lX%02lX", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    // إنشاء Color من رمز سداسي
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

class StickyNoteManager {
    static let shared = StickyNoteManager()
    private let publicDatabase = CKContainer(identifier: "iCloud.MorementCloud").publicCloudDatabase
    
    private var updateWorkItem: DispatchWorkItem?
    private let updateQueue = DispatchQueue(label: "com.example.StickyNoteUpdateQueue")
    
    func saveStickyNoteBatch(_ stickyNote: StickyNote, boardID: String, completion: @escaping (Result<StickyNote, Error>) -> Void) {
        updateWorkItem?.cancel()
        
        updateWorkItem = DispatchWorkItem { [weak self] in
            self?.saveStickyNoteToCloud(stickyNote, boardID: boardID, completion: completion)
        }
        
        if let workItem = updateWorkItem {
            updateQueue.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func saveStickyNoteToCloud(_ stickyNote: StickyNote, boardID: String, completion: @escaping (Result<StickyNote, Error>) -> Void) {
        print("Attempting to save sticky note with text: \(stickyNote.text)")
        if let recordID = stickyNote.recordID {
            publicDatabase.fetch(withRecordID: recordID) { [weak self] fetchedRecord, error in
                guard let self = self else { return }
                
                if let existingRecord = fetchedRecord {
                    self.updateStickyNoteRecord(existingRecord, with: stickyNote, boardID: boardID, completion: completion)
                } else if let error = error {
                    print("Error fetching record: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            let newRecord = CKRecord(recordType: "StickyNote")
            updateStickyNoteRecord(newRecord, with: stickyNote, boardID: boardID, completion: completion)
        }
    }
    
    private func updateStickyNoteRecord(_ record: CKRecord, with stickyNote: StickyNote, boardID: String, completion: @escaping (Result<StickyNote, Error>) -> Void) {
        print("Updating record with text: \(stickyNote.text)")
        record["text"] = stickyNote.text
        record["positionX"] = Double(stickyNote.position.x)
        record["positionY"] = Double(stickyNote.position.y)
        record["scale"] = Double(stickyNote.scale)
        record["color"] = stickyNote.color.toHex()
        record["isBold"] = stickyNote.isBold ? 1 : 0
        record["rotation"] = stickyNote.rotation.degrees
        
        let boardReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none)
        record["boardID"] = boardReference
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        modifyOperation.modifyRecordsCompletionBlock = { [weak self] savedRecords, deletedRecordIDs, error in
            DispatchQueue.main.async {
                if let savedRecord = savedRecords?.first {
                    let savedNote = StickyNote(
                        text: savedRecord["text"] as? String ?? "",
                        position: CGPoint(x: savedRecord["positionX"] as? Double ?? 0.0, y: savedRecord["positionY"] as? Double ?? 0.0),
                        scale: CGFloat(savedRecord["scale"] as? Double ?? 1.0),
                        color: Color(hex: savedRecord["color"] as? String ?? "#FFFF00"),
                        isBold: (savedRecord["isBold"] as? Int64 ?? 0) == 1,
                        rotation: Angle(degrees: savedRecord["rotation"] as? Double ?? 0),
                        recordID: savedRecord.recordID
                    )
                    completion(.success(savedNote))
                } else if let error = error {
                    if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                        self?.publicDatabase.fetch(withRecordID: record.recordID) { fetchedRecord, fetchError in
                            if let fetchedRecord = fetchedRecord {
                                self?.updateStickyNoteRecord(fetchedRecord, with: stickyNote, boardID: boardID, completion: completion)
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
    
    func fetchStickyNotes(forBoardID boardID: String, completion: @escaping (Result<[StickyNote], Error>) -> Void) {
        let predicate = NSPredicate(format: "boardID == %@", CKRecord.Reference(recordID: CKRecord.ID(recordName: boardID), action: .none))
        let query = CKQuery(recordType: "StickyNote", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching sticky notes: \(error)")
                    completion(.failure(error))
                } else if let records = records {
                    let stickyNotes = records.map { record in
                        let note = StickyNote(
                            text: record["text"] as? String ?? "",
                            position: CGPoint(x: record["positionX"] as? Double ?? 0.0, y: record["positionY"] as? Double ?? 0.0),
                            scale: CGFloat(record["scale"] as? Double ?? 1.0),
                            color: Color(hex: record["color"] as? String ?? "#FFFF00"),
                            isBold: (record["isBold"] as? Int64 ?? 0) == 1,
                            rotation: Angle(degrees: record["rotation"] as? Double ?? 0),
                            recordID: record.recordID
                        )
                        print("Fetched sticky note with text: \(note.text)")
                        return note
                    }
                    completion(.success(stickyNotes))
                } else {
                    completion(.success([]))
                }
            }
        }
    }

    
    func deleteStickyNote(_ stickyNote: StickyNote, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let recordID = stickyNote.recordID else {
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
