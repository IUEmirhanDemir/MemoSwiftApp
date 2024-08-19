//
//  MemoData.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//

import Foundation

/// `MemoData` is a struct that represents a memo within the MemoSwiftApp.
public struct MemoData {
    
    /// The unique identifier for the memo.
    var id: String
    
    /// The title of the memo.
    var title: String
    
    /// The detailed content of the memo.
    var details: String
    
    /// The date and time when the reminder for the memo is set.
    var reminderDate: Date
}
