//
//  UserDataManager.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import FirebaseFirestore

/// `Users` is a struct that represents user information within the MemoSwiftApp.
public struct Users {
    
    /// The unique identifier for the user.
    let userId: String
    
    /// The email address of the user.
    let email: String
}

/// `UserDataManager` is a singleton class responsible for managing user data within the MemoSwiftApp.
final class UserDataManager {
    
    /// Shared instance of `UserDataManager` to be used throughout the app.
    static let shared = UserDataManager()
    
    /// Private initializer to ensure `UserDataManager` is only instantiated once.
    private init() {}
    
    /// Creates a new user in the Firestore database.
    ///
    /// This method saves the user information in the Firestore database using the provided authentication data.
    /// - Parameter auth: The `AuthDataStructure` object containing the user's authentication details.
    /// - Throws: An error if the user data could not be created in the database.
    func createNewUser(auth: AuthDataStructure) async throws {
        let userData: [String: Any] = [
            "user_id": auth.uuid,
            "email": auth.email
        ]
        
        try await Firestore.firestore().collection("user").document(auth.uuid).setData(userData, merge: false)
    }
    
    /// Retrieves user information from the Firestore database.
    ///
    /// This method fetches the user data from the Firestore database for the specified user ID.
    /// - Parameter userId: The unique identifier of the user.
    /// - Throws: An error if the user data could not be retrieved from the database.
    /// - Returns: A `Users` object containing the retrieved user information.
    func getUser(userId: String) async throws -> Users {
        let snapshot = try await Firestore.firestore().collection("user").document(userId).getDocument()
        
        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        guard let userId = data["user_id"] as? String, let email = data["email"] as? String else {
            // Throw a more specific error if the required fields are not available
            throw NSError(domain: "UserDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Required user data fields are missing"])
        }
        
        return Users(userId: userId, email: email)
    }
}
