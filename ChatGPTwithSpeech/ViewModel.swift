//
//  ViewModel.swift
//  ChatGPTwithSpeech
//
//  Created by 林 政樹 on 2023/02/14.
//

import Foundation
import SwiftUI
import OpenAISwift
import Combine

struct ChatModel: Hashable {
    var text: String
    var isMe: Bool
}

protocol ViewModelProtocol:ObservableObject {
    var models: [ChatModel] { get }
    var isAsking: Bool { get }
    func setup()
    func askChatGPT()
    func endChatGPT()
}

final class ViewModel: ViewModelProtocol {
    @Published public var models:[ChatModel] = []
    @Published var isAsking: Bool = false
    
    private let recognizer:SpeechRecognizerProtocol = SpeechRecognizer()
    private let speech: SpeechSynthesizer = SpeechSynthesizer()
    
    private var client: OpenAISwift?
    private var cancellables = Set<AnyCancellable>()
    
    private let authToken = ""

    func setup() {
        client = OpenAISwift(authToken: authToken)
        
        recognizer.setup()
        recognizer.errorSubject.sink { error in
            switch error {
            case .needRecognizePermit:
                self.add(text: "「設定」から音声認識の許可をしてください。", isMe: false)
                break
            case .needRecordPermit:
                self.add(text: "「設定」からマイクの許可をしてください。", isMe: false)
                break
            case .failRecognize:
                self.add(text: "もう一度お願いします。", isMe: false)
                break
            }
        }.store(in: &cancellables)
        
        recognizer.recognizedTextSubject.sink { text in
            self.add(text: text, isMe: true)
        }.store(in: &cancellables)
        
        recognizer.didFinishSubject.sink { text in
            self.isAsking = true
            self.send(text: text) { response in
                self.add(text: response, isMe: false)
                self.isAsking = false
            }
        }.store(in: &cancellables)
        
        
        add(text: "こんにちは。\nご用件は何ですか？", isMe: false)
    }
    
    func askChatGPT() {
        speech.stopImmediatly()
        recognizer.startRecognizing()
    }
    
    func endChatGPT() {
        recognizer.stopRecognizing()
    }
    
    func add(text: String, isMe: Bool) {
        if isMe == false {
            speech.stopImmediatly()
            speech.play(text: text)
            
            models.append(.init(text: text, isMe: false))
            return
        }
        
        guard let last = models.last else { return }
        if last.isMe == true {
            models[models.count - 1].text = text
        } else {
            models.append(.init(text: text, isMe: true))
        }
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    let output = model.choices.first?.text ?? ""
                    completion(output)
                    break
                case .failure(let error):
                    print("error: ", error.localizedDescription)
                    completion("失敗しました。もう一度お願いします。")
                    break
                }
            }
        })
    }
}
