//
//  AuthDataStructure.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import FirebaseAuth

/// `AuthDataStructure` is a struct that encapsulates authentication data for a user within the MemoSwiftApp.
public struct AuthDataStructure {
    
    /// The unique identifier (UUID) for the authenticated user.
    let uuid: String
    
    /// The email address of the authenticated user, if available.
    let email: String?
    
    /// Initializes a new `AuthDataStructure` instance using a `User` object from FirebaseAuth.
    ///
    /// - Parameter user: The `User` object provided by FirebaseAuth.
    init(user: User) {
        self.uuid = user.uid
        self.email = user.email
    }
}
