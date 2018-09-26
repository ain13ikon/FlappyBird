//
//  ViewController.swift
//  FlappyBird
//
//  Created by きたむら on 2018/09/21.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //viewをSKViewに型変換する
        let skView = self.view as! SKView

        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
        //BGMの再生
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "kenka", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        //再生
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

}

