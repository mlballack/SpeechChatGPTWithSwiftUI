//
//  SpeechSynthesizer.swift
//  ChatGPTwithSpeech
//
//  Created by 林 政樹 on 2023/02/15.
//

import AVFoundation
import Combine

final class SpeechSynthesizer: NSObject {
    let isSpeeching = PassthroughSubject<Bool, Never>()

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        self.synthesizer.delegate = self
    }

    static func voices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }.sorted { voice1, voice2 in
            voice1.name < voice2.name
        }
    }

    public func play(text: String) {
        self._play(
            text: text,
            speechRate: 0.5,
            pitchMultiplier: 1.0,
            voiceType: 0,
            speechVolume: 1.0
        )
    }
    
    private func _play(text: String, speechRate: Float, pitchMultiplier: Float, voiceType: Int, speechVolume: Float) {
        isSpeeching.send(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.pitchMultiplier = pitchMultiplier

        let voice = voice(for: voiceType)
        if let voice = AVSpeechSynthesisVoice(identifier: voice.identifier) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        }
        utterance.volume = speechVolume
        synthesizer.speak(utterance)
    }

    public func stopImmediatly() {
        if synthesizer.isSpeaking == false { return }
        synthesizer.stopSpeaking(at: .immediate)
    }

    private func voice(for voiceType: Int) -> AVSpeechSynthesisVoice {
        let voices = SpeechSynthesizer.voices()
        let index: Int = voiceType >= voices.count ? voices.count - 1 : voiceType
        return voices[index]
    }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeeching.send(false)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeeching.send(false)
    }
}
