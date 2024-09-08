//
//  Bible_Verse_PickerApp.swift
//  Bible Verse Picker
//
//  Created by Vernon AME on 9/8/24.
//

import SwiftUI

@main
struct Bible_Verse_PickerApp: App {
    @State var connectedVerseContent = ""
    var body: some Scene {
        WindowGroup {
            BibleVersePicker(connectedVerseContent: $connectedVerseContent)
        }
    }
}
