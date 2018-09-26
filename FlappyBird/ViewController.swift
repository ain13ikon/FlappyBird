//
//  ViewController.swift
//  FlappyBird
//
//  Created by きたむら on 2018/09/21.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //viewをSKViewに型変換する
        let skView = self.view as! SKView

        //FPSを表示する
        //FPSとは１秒あたりに表示されるフレームの数（frames per secondの略）
        skView.showsFPS = true
        
        //ノードの数を表示する
        //ノードは画面構成要素(画像、テキストなど)
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
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

