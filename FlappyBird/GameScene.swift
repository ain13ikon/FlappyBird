//
//  GameScene.swift
//  FlappyBird
//
//  Created by きたむら on 2018/09/21.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    
    //衝突判定用カテゴリー
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    
    //スコア
    var score = 0
    let userDefaults:UserDefaults = UserDefaults.standard       //memo:データを保存するのに用いる
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!

    //SKView上にシーンが表示された時に呼ばれるメソッド
    //画面構成や初期設定に関する処理を記述する
    override func didMove(to view: SKView) {
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self

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
        
        setupScoreLabel()
        
    }
    
    //スコアラベルノードの初期設定を行う
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    //鳥を作成する
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
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = self.birdCategory
        bird.physicsBody?.contactTestBitMask = self.groundCategory | self.wallCategory
        bird.physicsBody?.collisionBitMask = self.groundCategory | self.wallCategory
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    //雲を作成する
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
    
    //地面を作成する
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
            
            //自身のカテゴリー設定
            groundSprite.physicsBody?.categoryBitMask = self.groundCategory
            // 衝突の時に動かないように設定する
            groundSprite.physicsBody?.isDynamic = false   // 重力の影響を受けるか
            

            // スクロールノードに地面スプライトを追加する
            scrollNode.addChild(groundSprite)
            
            print("\(i)個目の地面スプライトを追加")
            
        }
    }
    
    //壁を作成してwallNodeに追加する（wallNodeはscrollNodeに追加済み）
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
            let wallPairNode = SKNode() //上下の壁＋スコアノードを配置していく
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
                //Y軸中央に壁上部が一致ーランダムの半分（なぜ半分？→適当　後であげる分下げておく）
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
            underWall.physicsBody?.categoryBitMask = self.wallCategory
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
            upperWall.physicsBody?.categoryBitMask = self.wallCategory
            // 衝突の時に動かないように設定する
            upperWall.physicsBody?.isDynamic = false
            wallPairNode.addChild(upperWall)
            
            //通り抜け用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upperWall.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperWall.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wallPairNode.addChild(scoreNode)
            
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
        if scrollNode.speed > 0 {
            //ゲーム中の場合(スクロールが動いている)//
            // 鳥の(落下)速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }else if bird.speed == 0{
            //ゲームオーバーの場合(鳥が止まっている)//
            //memo:単にelseとしないのはスクロールが止まってから鳥が落ちるまでの時間差でタップされ反応するのを防ぐため？
            //リスタートさせる
            restart()
        }
    }
    
    //衝突時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        print("衝突")
        // ゲームオーバーのときは何もしない(壁→地面で２度衝突するため)
        if scrollNode.speed <= 0 {
            return
        }

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score: \(score)"
            
            //ベストスコアと比較
            var bestScore = userDefaults.integer(forKey: "BEST")
            print("現在のベストスコアは\(bestScore)")
            if score > bestScore {
                bestScore = score
                print("ベストスコア更新: \(bestScore)")
                bestScoreLabelNode.text = "Best Score: \(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0    //全てのノード・スプライトをscrollNodeに追加しているのでまとめて止められる？
            
            //地面まで落下させるため、壁と衝突しないようにする
            bird.physicsBody?.collisionBitMask = groundCategory
            
            //鳥を回転させる(アクションを設定)
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
        
    }
    
    func restart(){
        score = 0
        scoreLabelNode.text = "Score: \(score)"
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
    }

    
}
