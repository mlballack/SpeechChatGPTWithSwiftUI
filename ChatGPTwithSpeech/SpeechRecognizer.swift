//
//  SpeechRecognizer.swift
//  ChatGPTwithSpeech
//
//  Created by 林 政樹 on 2023/02/13.
//

import Foundation
import AVFoundation
import Speech
import Combine

/*
 [Warning]
 Error Domain=kLSRErrorDomain Code=201 "Siri and Dictation are disabled"
 https://stackoverflow.com/questions/70208377/ipad-pro3-m1-ios-15-0-code-201-siri-and-dictation-are-disabled
 Failed to access assets
 https://developer.apple.com/forums/thread/703770
 */

protocol SpeechRecognizerProtocol {
    var errorSubject: PassthroughSubject<SpeechRecognizer.RecognizeError, Never> { get }
    var recognizedTextSubject: PassthroughSubject<String, Never> { get }
    var didFinishSubject: PassthroughSubject<String, Never> { get }
    func setup()
    func startRecognizing()
    func stopRecognizing()
}

final class SpeechRecognizer: SpeechRecognizerProtocol {
    
    enum RecognizeError: Error {
        case needRecordPermit
        case needRecognizePermit
        case failRecognize
    }
    
    var errorSubject = PassthroughSubject<RecognizeError, Never>()
    var recognizedTextSubject = PassthroughSubject<String, Never>()
    var didFinishSubject = PassthroughSubject<String, Never>()
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task : SFSpeechRecognitionTask?
    private let recorder: AudioRecorder = AudioRecorder()
    private let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    
    private var recognizedText = ""
    private var isFinal = false
    
    public func setup() {
        recorder.setup { [weak self] buffer in
            guard let self = self else { return }
            self.request?.append(buffer)
        }
        prepareRecognizing()
    }
    
    public func startRecognizing() {
        SFSpeechRecognizer.requestAuthorization { available in
            if available != .authorized {
                self.errorSubject.send(.needRecognizePermit)
                return
            }
            self.prepareRecognizing()
            

            self._startRecognizing { error in
                guard let error = error else { return }
                self.errorSubject.send(error)
            }
        }
    }
    
    public func stopRecognizing() {
        isFinal = true
        recorder.stop()
        task?.cancel()
    }
    
    private func prepareRecognizing() {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { fatalError() }
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false

        self.task?.cancel()
        self.task = nil
        
        self.task = recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                print("error: ", error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            self.isFinal = result.isFinal
            if self.isFinal == true {
                if let last = self.recognizedText.last, last != "。" {
                    self.recognizedText += "。"
                }
                self.didFinishSubject.send(self.recognizedText)
                self.recognizedText = ""
                self.task?.cancel()
                self.recorder.stop()
                self.request = nil
                self.task = nil
                return
            }
 
            self.recognizedText = result.bestTranscription.formattedString
            self.recognizedTextSubject.send(self.recognizedText)
        }
    }
    
    private func _startRecognizing(errorHandler: @escaping (RecognizeError?)->Void) {
        isFinal = false
        recorder.startWith { error in
            guard let error = error else { return }
            switch error {
            case .needPermit:
                errorHandler(.needRecordPermit)
            case .failRecord:
                errorHandler(.failRecognize)
            }
        }
    }
}
