//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Javier Menendez on 7/3/15.
//  Copyright (c) 2015 Menulio Baxter Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    func initAudioSystem(){
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize audio engine with received audio
        initAudioSystem()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        // Create rate effect (pitch 0 mantains recorded pitch)
        var timePitchEffect = createTimePitchUnit(1.8, pitch:0)
        // Play audio with effect
        play(timePitchEffect)
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        // Create rate effect (pitch 0 mantains recorded pitch)
        var timePitchEffect = createTimePitchUnit(0.5, pitch:0)
        // Play audio with effect
        play(timePitchEffect)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        // Create pitch effect (rate 1 maintains recorded rate)
        var timePitchEffect = createTimePitchUnit(1, pitch: 1000)
        // Play audio with effect
        play(timePitchEffect)
        
    }
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        // Create pitch effect (rate 1 maintains recorded rate)
        var timePitchEffect = createTimePitchUnit(1, pitch: -1000)
        // Play audio with effect
        play(timePitchEffect)
    }
    
    @IBAction func playParrotAudio(sender: UIButton) {
        // Create delay unit to provide effect
        var delayEffect = createDelayUnit(1)
        // Play audio with effect
        play(delayEffect)
    }
    
    @IBAction func playCaveAudio(sender: UIButton) {
        // Create reverb unit to provide effect
        var reverbEffect = createReverbUnit(AVAudioUnitReverbPreset.Cathedral, mix: 30)
        // Play audio with effect
        play(reverbEffect)
    }
    
    func createDelayUnit(delay: NSTimeInterval) -> AVAudioUnitDelay{
        // returns audioUnit to add delay effect with parameters provided
        var delayUnit = AVAudioUnitDelay()
        delayUnit.delayTime = delay
        return delayUnit
    }
    
    func createReverbUnit(preset: AVAudioUnitReverbPreset, mix: Float) -> AVAudioUnitReverb{
        // returns audioUnit to add reverb effect with parameters provided
        var reverbUnit = AVAudioUnitReverb()
        reverbUnit.loadFactoryPreset(preset)
        reverbUnit.wetDryMix = mix
        return reverbUnit
    }
    
    func createTimePitchUnit(rate: Float, pitch: Float) -> AVAudioUnitTimePitch{
        // returns audioUnit to change the pitch of the audio
        var timePitchUnit = AVAudioUnitTimePitch()
        timePitchUnit.rate = rate
        timePitchUnit.pitch = pitch
        return timePitchUnit
    }

    @IBAction func stopAudio(sender: UIButton) {
        // Stops all audio from playing and returns recording to initial position
        resetPlayerandEngine()
    }
    
    func resetPlayerandEngine(){
        // Stops all audio from playing
        audioPlayer.stop()
        audioEngine.stop()
        // Returns recording to initial position
        audioEngine.reset()
    }
    
    func play(effect: AVAudioNode!){
        // reset player and engine to prevent errors
        resetPlayerandEngine();
        // init inputNode
        var inputNode = AVAudioPlayerNode()
        // Attach inputNode to effect and connect them through the engine to the outputNode
        attachEffect(inputNode, effect: effect)
        
        // Inform input node which file will play
        inputNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        // Start the audio engine
        audioEngine.startAndReturnError(nil)
        // play sound
        inputNode.play()
    }
    
    func attachEffect(inputNode: AVAudioNode!, effect: AVAudioNode!){
        // Attach inputNode to effect and connect them through the engine to the outputNode
        audioEngine.attachNode(inputNode)
        audioEngine.attachNode(effect)
        audioEngine.connect(inputNode, to: effect, format: nil)
        audioEngine.connect(effect, to:audioEngine.outputNode, format: nil)
    }
}
