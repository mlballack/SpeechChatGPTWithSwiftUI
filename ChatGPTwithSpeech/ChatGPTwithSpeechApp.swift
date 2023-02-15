//
//  ChatGPTwithSpeechApp.swift
//  ChatGPTwithSpeech
//
//  Created by Massaki Hayashi on 2023/02/13.
//

import SwiftUI

@main
struct ChatGPTwithSpeechApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel())
        }
    }
}
