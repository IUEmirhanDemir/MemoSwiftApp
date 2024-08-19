//
//  ContentView.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import SwiftUI

/// `ContentView` serves as the root view for the MemoSwiftApp, coordinating navigation between the sign-in view and the memo list view based on the user's authentication status.
struct ContentView: View {
    /// A state variable that tracks whether the sign-in view should be shown.
    @State private var showSignInView: Bool = false  // Default is false
      
    /// The body property defines the view structure and content for the ContentView.
    var body: some View {
        NavigationStack {
            if !showSignInView {
                // Displays the memo list view if the user is signed in.
                MemoListView(showSignInView: $showSignInView)
                    .animation(.easeInOut)
            } else {
                // Displays the sign-in email view if the user is not signed in.
                SignInEmailView(showSignInView: $showSignInView)
                    .animation(.easeInOut)
            }
        }
        .onAppear {
            // Checks if there is a currently authenticated user.
            let authUser = try? AuthManager.shared.getCurrentUser()
            // Sets showSignInView based on authentication status.
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            // Presents the login view in a full-screen cover when showSignInView is true.
            NavigationStack {
                LoginView(showSignInView: $showSignInView)
                    .animation(.easeInOut)
            }
        }
    }
}

// Preview configuration for ContentView.
#Preview {
    ContentView()
}
