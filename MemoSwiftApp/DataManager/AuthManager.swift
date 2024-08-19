//
//  AuthManager.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import FirebaseAuth

/// `AuthManager` is a singleton class responsible for managing authentication in the MemoSwiftApp.
final class AuthManager {
    
    /// Shared instance of `AuthManager` to be used throughout the app.
    static let shared = AuthManager()
    
    /// Private initializer to ensure `AuthManager` is only instantiated once.
    private init() {}
    
    /// Retrieves the currently authenticated user.
    ///
    /// This method returns the `AuthDataStructure` for the currently authenticated user, if one exists.
    /// - Throws: `URLError(.badServerResponse)` if no user is currently authenticated.
    /// - Returns: The `AuthDataStructure` representing the current user.
    func getCurrentUser() throws -> AuthDataStructure {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            throw URLError(.badServerResponse) // Consider creating a more specific error type for better clarity.
        }
        print("Current user found: UUID = \(user.uid), Email = \(user.email ?? "no email available")")
        return AuthDataStructure(user: user)
    }
    
    /// Creates a new user with the given email and password.
    ///
    /// This method creates a new user account using the provided email and password.
    /// - Parameters:
    ///   - email: The email address for the new user.
    ///   - password: The password for the new user.
    /// - Throws: An error if the user creation fails.
    /// - Returns: The `AuthDataStructure` representing the newly created user.
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataStructure {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataStructure(user: authDataResult.user)
    }
    
    /// Signs out the currently authenticated user.
    ///
    /// This method attempts to sign out the currently authenticated user. If an error occurs during sign-out,
    /// it is caught and ignored.
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    /// Signs in an existing user with the given email and password.
    ///
    /// This method authenticates an existing user using the provided email and password.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The password of the user.
    /// - Throws: An error if the sign-in fails.
    /// - Returns: The `AuthDataStructure` representing the authenticated user.
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataStructure {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataStructure(user: authDataResult.user)
    }
}
