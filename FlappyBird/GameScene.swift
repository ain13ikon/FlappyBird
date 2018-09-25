//
//  GameScene.swift
//  FlappyBird
//
//  Created by きたむら on 2018/09/21.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    //メモ：画面構成や初期設定に関する処理を記述する
    override func didMove(to view: SKView) {
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)

        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールの親ノードを用意してシーンに追加する
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        setCloud()
        setGround()
        setWall()
        setBird()
        
    }
    
    func setBird(){
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //2種類のテクスチャを交互に表示する
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)    // ←追加
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    func setCloud(){
        //雲画像を読み込む、画質・処理速度の設定
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //アクションの作成
        let moveCloudAction = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 5.0)
        let resetCloudAction = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        let cloudActions = SKAction.sequence([moveCloudAction, resetCloudAction])
        let scrollCloud = SKAction.repeatForever(cloudActions)
        
        //スプライトを必要数作成して、位置設定、アクション追加、ノードに追加
        let needNumber = Int(ceil(self.frame.size.width / cloudTexture.size().width) + 1)
        print("雲の必要数は\(needNumber)")
        for i in 0..<needNumber {
            let cloudSprite = SKSpriteNode(texture: cloudTexture)
            cloudSprite.position = CGPoint(
                x: cloudTexture.size().width * (0.5 + CGFloat(i)),
                y: self.frame.size.height - cloudTexture.size().height * 0.5
            )
            cloudSprite.zPosition = -100    //一番後ろにする
            
            cloudSprite.run(scrollCloud)
            scrollNode.addChild(cloudSprite)
            print("\(i)個目の雲スプライトを追加")
        }
    }
    
    func setGround(){
        //地面画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground") //SKTextureは画像を扱うもの
        groundTexture.filteringMode = .nearest
        //メモ：　filteringModeは画質と処理速度の設定を行う .nearest:画像が荒くなるが処理が速い　.linear:画像がきれいだが処理が遅い
        
        //画面を埋めるのに必要な枚数を計算
        let needNumber = Int(ceil(self.frame.size.width / groundTexture.size().width) + 1)
        print("必要な枚数は\(needNumber)")
        
        //地面をスクロールされるためのアクションを用意する
        //①画像１つ分を左にスクロールするアクションを作成
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        //②画像を元の位置に戻すアクションを作成
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        //①②のアクションを組み合わせたアクションを作成
        let actions = SKAction.sequence([moveGround, resetGround])
        //  actionsを繰り返すアクションを作成
        let repeatGround = SKAction.repeatForever(actions)
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {
            //テクスチャ(groundTexture)を指定してスプライトを作成する
            let groundSprite = SKSpriteNode(texture: groundTexture)
            //メモ：スプライトとは処理負荷を上げずに高速に画像を描画する仕組み
            
            // スプライトの表示する位置を指定する
            groundSprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),
                y: groundTexture.size().height * 0.5
            )
            //メモ：画像の中心の配置位置を指定している？
            
            //スプライトにアクションを登録
            groundSprite.run(repeatGround)
            
            // スプライトに物理演算を設定する
            groundSprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            // 衝突の時に動かないように設定する
            groundSprite.physicsBody?.isDynamic = false   // 重力の影響を受けるか
            

            // スクロールノードに地面スプライトを追加する
            scrollNode.addChild(groundSprite)
            
            print("\(i)個目の地面スプライトを追加")
            
        }
    }
    
    func setWall(){
        //壁画像を読み込む、画質・処理速度の設定
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //壁の動きのアクションを作成
        //移動距離を求める
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        //アクション①：場外まで移動
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        //アクション②：自身を取り除く
        let removeWall = SKAction.removeFromParent()
        //①②を組み合わせる
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //❶壁の生成を繰り返すアクションを作成
        let createWall = SKAction.run ({
            //ノードを作成
            let wallPairNode = SKNode()
            wallPairNode.position = CGPoint(
                //壁のスタート位置
                x: self.frame.size.width + wallTexture.size().width * 0.5,
                y: 0.0
            )
            wallPairNode.zPosition = -50    //地面＞壁＞雲
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
                //Y軸中央に壁上部が一致ーランダムの半分（なぜ半分？）
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定（？？？）
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            

            //下の壁を作成
            let underWall = SKSpriteNode(texture: wallTexture)
            underWall.position = CGPoint(x: 0.0, y: under_wall_y)  //壁のスタート位置からのずれ
            // スプライトに物理演算を設定する
            underWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            // 衝突の時に動かないように設定する
            underWall.physicsBody?.isDynamic = false
            wallPairNode.addChild(underWall)
            
            //上の壁を作成
            let upperWall = SKSpriteNode(texture: wallTexture)
            upperWall.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
                //下の壁の中心位置＋壁１つの高さ(下壁半分＋上壁半分)＋隙間
                //壁のスタート位置からのずれ
            // スプライトに物理演算を設定する
            upperWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            // 衝突の時に動かないように設定する
            upperWall.physicsBody?.isDynamic = false
            wallPairNode.addChild(upperWall)
            
            wallPairNode.run(wallAnimation)
            self.wallNode.addChild(wallPairNode)

        })
        //❷待ち時間のアクション
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //❶❷を組み合わせて繰り返すアクション
        let repeatCreateWall = SKAction.repeatForever(SKAction.sequence([createWall, waitAnimation]))
        
        wallNode.run(repeatCreateWall)
        
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 鳥の(落下)速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero
        
        // 鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
    }

    
}
