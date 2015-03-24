//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Javier Menendez on 2/3/15.
//  Copyright (c) 2015 Menulio Baxter Inc. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Set the state of the view to its initial step
        resetViewForRecording()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetViewForRecording(){
        // Restart audioRecorder
        audioRecorder = nil
        // restart progress label to its original value
        recordingInProgress.text = "tap to record"
        // Hide buttons
        prepareElementsForRecording(false)
    }
    
    func prepareElementsForRecording(flag: Bool){
        showButtons(flag)
        // Change the text of the label depending on flag
        if (flag){
            recordingInProgress.text = "recording (tap to pause)"
        } else {
            recordingInProgress.text = "tap to record"
        }
    }
    
    func showButtons(flag: Bool){
        // show or hide the buttons depending on flag
        stopButton.hidden = !flag
        restartButton.hidden = !flag
    }
    
    func prepareRecordingFile() -> NSURL!{
        // Define local dir
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        // Define file name using current Date
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // Return path to recording file
        return filePath
    }
    
    func startRecording(){
        // Show buttons and change label
        prepareElementsForRecording(true)
        // Get path for recording file
        var filePath = prepareRecordingFile()
        // Init recording session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // Inform audio recorder the file path to store the recording
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        // enable metering so the effects would be applied
        audioRecorder.meteringEnabled = true;
        
        // Define current view as AudioRecorderDelegate
        audioRecorder.delegate = self
        
        // get ready and start recording
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording(){
        // Hide buttons and restart label
        prepareElementsForRecording(false)
        // Stop and deactivate recorder
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }


    @IBAction func manageRecording(sender: UIButton) {
        if (audioRecorder == nil){
            // If first time pressed, start recording
            startRecording()
        } else {
            // If audioRecorder active, pause button behaviour
            pauseRecording()
        }
    }
    
    /*
    * Define a handler to trigger the action that will take place after pressing OK button in the alert
    */
    func startRecordingHandler(alert: UIAlertAction!){
        startRecording()
    }
    
    @IBAction func restartRecording(sender: UIButton) {
        // Set the state of the view to its initial step
        resetViewForRecording()
        
        // Show an alert for the user to know the recording has been restarted
        var alert = UIAlertController(title: "Recording restarted", message: "Press OK to continue", preferredStyle: UIAlertControllerStyle.Alert)
        // After pressin OK button, the recording will be restarted, as defined in handler
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: startRecordingHandler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag){
            // init the object that stores the recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            // Move to the next screen and send the audio object through the segue
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            // Hide buttons and restart label
            prepareElementsForRecording(false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // If stop was pressed, retrieve recorded audio and send the recorded audio to the next View
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    func pauseRecording() {
        if (audioRecorder.recording){
            // Pause recording and change label to "paused"
            audioRecorder.pause()
            recordingInProgress.text = "paused (tap to resume)"
            stopButton.hidden = true
        } else {
            // Resume recording and change label to "recording"
            audioRecorder.record()
            recordingInProgress.text = "recording (tap to pause)"
            stopButton.hidden = false
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        stopRecording()
    }
}

