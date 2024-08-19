//
//  MemoDataManager.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import FirebaseFirestore

/// `MemoManager` is a singleton class responsible for managing the CRUD operations for memos in the MemoSwiftApp.
final class MemoManager {
    
    /// Shared instance of `MemoManager` to be used throughout the app.
    static let shared = MemoManager()
    
    /// Private initializer to ensure `MemoManager` is only instantiated once.
    private init() {}

    /// Creates a new memo for a specific user.
    ///
    /// This method saves a new memo to the Firestore database under the specified user's collection.
    /// - Parameters:
    ///   - userId: The unique identifier of the user.
    ///   - memo: The `MemoData` object containing the memo details to be saved.
    /// - Throws: An error if the memo could not be created in the database.
    func createMemo(for userId: String, memo: MemoData) async throws {
        let db = Firestore.firestore()
        let memoData: [String: Any] = [
            "title": memo.title,
            "details": memo.details,
            "reminderDate": Timestamp(date: memo.reminderDate)
        ]
        try await db.collection("user").document(userId).collection("memos").document(memo.id).setData(memoData)
    }

    /// Fetches all memos for a specific user.
    ///
    /// This method retrieves all memos associated with the specified user from the Firestore database.
    /// - Parameter userId: The unique identifier of the user.
    /// - Throws: An error if the memos could not be fetched from the database.
    /// - Returns: An array of `MemoData` objects representing the user's memos.
    func fetchMemos(for userId: String) async throws -> [MemoData] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("user").document(userId).collection("memos").getDocuments()

        return snapshot.documents.compactMap { doc -> MemoData? in
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let details = data["details"] as? String,
                  let reminderDate = (data["reminderDate"] as? Timestamp)?.dateValue() else { return nil }

            return MemoData(id: doc.documentID, title: title, details: details, reminderDate: reminderDate)
        }
    }

    /// Updates an existing memo for a specific user.
    ///
    /// This method updates the details of a memo in the Firestore database for the specified user.
    /// - Parameters:
    ///   - userId: The unique identifier of the user.
    ///   - memo: The `MemoData` object containing the updated memo details.
    /// - Throws: An error if the memo could not be updated in the database.
    func updateMemo(for userId: String, memo: MemoData) async throws {
        let db = Firestore.firestore()
        let memoData: [String: Any] = [
            "title": memo.title,
            "details": memo.details,
            "reminderDate": Timestamp(date: memo.reminderDate)
        ]
        try await db.collection("user").document(userId).collection("memos").document(memo.id).setData(memoData, merge: true)
    }

    /// Deletes a memo for a specific user.
    ///
    /// This method removes a memo from the Firestore database for the specified user.
    /// - Parameters:
    ///   - userId: The unique identifier of the user.
    ///   - memoId: The unique identifier of the memo to be deleted.
    /// - Throws: An error if the memo could not be deleted from the database.
    func deleteMemo(for userId: String, memoId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("user").document(userId).collection("memos").document(memoId).delete()
    }
}
