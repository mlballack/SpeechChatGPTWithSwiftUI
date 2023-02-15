//
//  AudioRecorder.swift
//  ChatGPTwithSpeech
//
//  Created by Massaki Hayashi on 2023/02/14.
//

import Foundation
import AVFoundation

final class AudioRecorder {
    
    enum RecordError: Error {
        case needPermit
        case failRecord
    }
    
    private var engine = AVAudioEngine()
    public var completeHandler: ((AVAudioPCMBuffer) -> Void)?

    public func setupAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    public func setup(bufferBlock: @escaping ((AVAudioPCMBuffer) -> Void)) {
        try? setupAudioSession()
        
        engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            bufferBlock(buffer)
        }
    }
 
    public func startWith(errorHandler: @escaping (RecordError?)->Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { available in
            if available == false {
                errorHandler(.needPermit)
                return
            }
            
            do {
                try self._start()
            } catch let error {
                print("error: ", error.localizedDescription)
                errorHandler(.failRecord)
            }
        }
    }

    public func stop() {
        engine.stop()
    }
    
    private func _start() throws {
        engine.prepare()
        try engine.start()
    }
}
