//
//  LoginView.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation
import SwiftUI

/// `LoginView` is a SwiftUI view that provides the interface for users to navigate to the sign-in process.
struct LoginView: View {
    
    /// A binding variable that controls whether the sign-in view is presented.
    @Binding var showSignInView: Bool
    
    /// The body of the `LoginView`, which contains the user interface elements.
    var body: some View {
        VStack {
            // Navigation link to the SignInEmailView.
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with Mail")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        LoginView(showSignInView: .constant(false))
    }
}
