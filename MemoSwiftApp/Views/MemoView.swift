//
//  MemoView.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import SwiftUI

/// `ProfileViewModel` manages user profile information within the app.
@MainActor
final class ProfileViewModel: ObservableObject {
    /// Published user information, accessible to the view for display.
    @Published private(set) var user: Users?
    
    /// Loads the current user's data from the user management services.
    func loadCurrentUser() async {
        do {
            let result = try AuthManager.shared.getCurrentUser()
            self.user = try await UserDataManager.shared.getUser(userId: result.uuid)
        } catch {
            print("Failed to load current user: \(error)")
        }
    }
    
    /// Logs out the current user.
    func logOut() {
        AuthManager.shared.signOut()
    }
}

/// `MemoViewModel` manages memo data and interactions within the app.
final class MemoViewModel: ObservableObject {
    /// A list of memos published for the view.
    @Published var memos: [MemoData] = []
    /// State for tracking if a new memo is being added.
    @Published var isAddingNewMemo = false
    /// Title for a new memo.
    @Published var newMemoTitle = ""

    /// Adds a new memo to the database and refreshes the memo list.
    func addMemo() async {
        let newMemo = MemoData(id: UUID().uuidString, title: newMemoTitle, details: "", reminderDate: Date())
        do {
            let userId = try AuthManager.shared.getCurrentUser().uuid
            try await MemoManager.shared.createMemo(for: userId, memo: newMemo)
            newMemoTitle = ""
            await fetchMemos()
        } catch {
            print("Error creating memo: \(error)")
        }
    }
    
    /// Fetches all memos for the current user.
    func fetchMemos() async {
        do {
            let userId = try AuthManager.shared.getCurrentUser().uuid
            memos = try await MemoManager.shared.fetchMemos(for: userId)
        } catch {
            print("Error fetching memos: \(error)")
        }
    }
    
    /// Updates a specific memo and refreshes the list.
    func updateMemo(memo: MemoData) async {
        do {
            let userId = try AuthManager.shared.getCurrentUser().uuid
            try await MemoManager.shared.updateMemo(for: userId, memo: memo)
            NotifyManager.shared.scheduleNotification(for: memo)
            await fetchMemos()
        } catch {
            print("Error updating memo: \(error)")
        }
    }
    
    /// Deletes a specific memo and refreshes the list.
    func deleteMemo(memo: MemoData) async {
        do {
            let userId = try AuthManager.shared.getCurrentUser().uuid
            try await MemoManager.shared.deleteMemo(for: userId, memoId: memo.id)
            await fetchMemos()
        } catch {
            print("Error deleting memo: \(error)")
        }
    }
}

/// `MemoListView` represents the main view for displaying user profiles and memo lists.
struct MemoListView: View {
    /// View model for managing memo data.
    @StateObject private var viewModel = MemoViewModel()
    /// View model for managing user profile data.
    @StateObject private var viewModel2 = ProfileViewModel()
    /// State to control editing mode.
    @State private var isEditing = false
    /// Binding from parent view to control visibility.
    @Binding var showSignInView: Bool
    
    var body: some View {
        let user = viewModel2.user
        NavigationView {
            List {
                Section(header: Text("Profile").font(.subheadline)) {
                    if user != nil {
                        Text("User ID \(user!.userId)")
                        Text("Email \(user!.email)")
                        Button("Log Out") {
                            Task {
                                do {
                                    viewModel2.logOut()
                                    showSignInView = true
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Memos").font(.subheadline)) {
                    ForEach($viewModel.memos, id: \.id) { $memo in
                        if isEditing {
                            HStack {
                                TextField("Edit Title", text: $memo.title, onCommit: {
                                    Task {
                                        await viewModel.updateMemo(memo: memo)
                                    }
                                })
                                .foregroundColor(.gray)
                                
                                Spacer()
                                Button(action: {
                                    Task {
                                        await viewModel.deleteMemo(memo: memo)
                                    }
                                }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                        .animation(.easeInOut)
                                }
                            }
                        } else {
                            NavigationLink(destination: MemoDetailView(memo: memo, viewModel: viewModel)) {
                                Text(memo.title)
                            }
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            Task {
                                await viewModel.deleteMemo(memo: viewModel.memos[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle(user?.email ?? "")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                            .animation(.easeInOut)
                    }
                    Button("Add Memo") {
                        viewModel.isAddingNewMemo = true
                    }
                    .animation(.easeInOut)
                }
            }
            .sheet(isPresented: $viewModel.isAddingNewMemo) {
                NavigationView {
                    Form {
                        TextField("Memo Title", text: $viewModel.newMemoTitle)
                            .animation(.easeInOut)
                        
                        Button("Save") {
                            Task {
                                await viewModel.addMemo()
                                viewModel.isAddingNewMemo = false
                            }
                        }
                        .animation(.easeInOut)
                        .disabled(viewModel.newMemoTitle.isEmpty)
                    }
                    .navigationTitle("New Memo")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                viewModel.isAddingNewMemo = false
                            }
                            .animation(.easeInOut)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMemos()
                    try? await viewModel2.loadCurrentUser()
                }
            }
        }
    }
}

/// `MemoDetailView` provides a detailed view for a specific memo.
struct MemoDetailView: View {
    @State var memo: MemoData
    @ObservedObject var viewModel: MemoViewModel
    @State private var showingAlert:Bool = false

    var body: some View {
        Form {
            TextField("Title", text: $memo.title)
            TextField("Details", text: $memo.details)
            DatePicker("Reminder", selection: $memo.reminderDate, displayedComponents: [.date, .hourAndMinute])
            Button("Save Changes") {
                Task {
                    await viewModel.updateMemo(memo: memo)
                    NotifyManager.shared.requestNotificationPermission()
                    NotifyManager.shared.scheduleNotification(for: memo)
                    showingAlert = true
                }
            }
            .animation(.easeInOut)
            
            .alert("Changes Saved", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
                    .animation(.easeInOut)
            }
        }
        .navigationTitle(memo.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Preview provider for `MemoListView`.
struct MemoListView_Previews: PreviewProvider {
    static var previews: some View {
        MemoListView(showSignInView: .constant(false))
    }
}
