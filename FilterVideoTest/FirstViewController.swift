//
//  FirstViewController.swift
//  FilterVideoTest
//
//  Created by sm2 on 2018/1/22.
//  Copyright © 2018年 sm2. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation
import AVKit

class FirstViewController: UIViewController {
    @IBOutlet var outputView: UIView!
    
    var playerController = AVPlayerViewController()
    var player: AVPlayer?
    
    var videoCamera: GPUImageVideoCamera!
    var customFilter: GPUImageFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: AVCaptureDevice.Position.back)
        self.videoCamera?.outputImageOrientation = UIInterfaceOrientation.portrait
        
        //custom filter in CustomShader.fsh
        self.customFilter = GPUImageFilter.init(fragmentShaderFromFile: "CustomShader")
        //GPUImage filters
        //self.customFilter = GPUImageSketchFilter()
        var filteredVideoView = GPUImageView.init(frame: outputView.bounds)
        
        // Add the view somewhere so it's visible
        self.videoCamera?.addTarget(self.customFilter!)
        self.customFilter?.addTarget(filteredVideoView)
        self.videoCamera?.startCapture()
        self.outputView.addSubview(filteredVideoView)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    var isCatpturing = false
    @IBAction func captureButtonPressed(){
        if isCatpturing == false{
            self.startRecord()
            self.isCatpturing = true
        }else{
            self.stopRecord()
            self.isCatpturing = false
        }
    }
    
    var movieWriter: GPUImageMovieWriter!
    var videoURL: URL!
    func startRecord(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.videoURL = paths[0].appendingPathComponent("TmpVideo.mp4")
        try? FileManager.default.removeItem(at: self.videoURL)
        
        self.movieWriter = GPUImageMovieWriter.init(movieURL: self.videoURL, size: CGSize(width: 720, height: 1280))
        self.movieWriter.encodingLiveVideo = true
        self.customFilter.addTarget(self.movieWriter!)
        
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        self.movieWriter.startRecording()
    }
    
    func stopRecord(){
        self.customFilter.removeTarget(self.movieWriter!)
        self.videoCamera.audioEncodingTarget = nil;
        self.movieWriter.finishRecording()
        var customPhotoAlbum = CustomPhotoAlbum()
        customPhotoAlbum.saveVideo(self.videoURL)
        
        self.player = AVPlayer(url: URL(fileURLWithPath: self.videoURL.path))
        self.playerController.player = self.player
        self.present(self.playerController, animated: true, completion: {
            self.playerController.player?.play()
        })
    }

}

