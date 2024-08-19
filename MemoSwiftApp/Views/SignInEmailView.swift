//
//  SignInEmailView.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import SwiftUI

/// `SignInEmailViewModel` is an `ObservableObject` that manages the state and logic for the sign-in and sign-up process using email and password.
final class SignInEmailViewModel: ObservableObject {
    
    /// The email address entered by the user.
    @Published var email = ""
    
    /// The password entered by the user.
    @Published var password = ""
    
    /// Creates a new user account with the provided email and password.
    ///
    /// This method checks that the email and password fields are not empty, then calls `AuthManager` to create a new user and stores the user's data using `UserDataManager`.
    /// - Throws: An error if the sign-up process fails.
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email or Password")
            return
        }
        let c = try await AuthManager.shared.createUser(email: email, password: password)
        try await UserDataManager.shared.createNewUser(auth: c)
    }
    
    /// Signs in an existing user with the provided email and password.
    ///
    /// This method checks that the email and password fields are not empty, then calls `AuthManager` to sign in the user.
    /// - Throws: An error if the sign-in process fails.
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email or Password")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
}

/// `SignInEmailView` is a SwiftUI view that provides an interface for users to sign in or sign up with an email and password.
struct SignInEmailView: View {
    
    /// The view model that handles the sign-in and sign-up logic.
    @StateObject private var viewModel = SignInEmailViewModel()
    
    /// A binding that controls whether the sign-in view is shown.
    @Binding var showSignInView: Bool
    
    /// The body of the `SignInEmailView`, which contains the user interface elements for signing in or signing up.
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Password...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            print("Error during sign-up: \(error)")
                        }
                        
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        } catch {
                            print("Error during sign-in: \(error)")
                        }
                    }
                }) {
                    Text("Sign in")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In with Email")
        }
        .animation(.easeInOut)
    }
}

// Preview
struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}
