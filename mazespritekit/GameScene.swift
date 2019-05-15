//
//  GameScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import SocketIO

struct Player {
    var id:String?
    var x:Double?
    var y:Double?
    var number:Int?
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Socket
    let socketManager = SocketManager(socketURL: URL(string: "http://163.172.6.169:3000")!)
    var socket:SocketIOClient?
    
    // Game
    var playerId:String = "1"
    var allPlayers:[String:PlayerControllerDelegate] = [:]
    let manager = CMMotionManager()
    var goal:SKNode = SKNode()
    var velocity:CGVector? = CGVector()
    
    
    
    override func didMove(to view: SKView) {
        
        // Handle Socket
        self.playerId = NSUUID().uuidString
        
        
        socket = socketManager.defaultSocket
        
        socket?.on(clientEvent: .connect, callback: { data, ack  in
            print("--> \(data)")
        })
        
        socket?.on("player_logged_in", callback: { data, ack  in
            print(data)
            
            guard let dict = data[0] as? NSDictionary else {return}
            
            guard let id = dict["id"] else {return}
            guard let number = dict["number"] else {return}
            
            self.createPlayer(playerId: id as! String, number: number as! Int)
        })
        
        socket?.on("", callback: { data, ack  in
            print(data)
        })
        
        
        socket?.connect()
        
        

    
        
        // set up game
        self.physicsWorld.contactDelegate = self
        goal = self.childNode(withName: "goal")!
        goal.physicsBody?.affectedByGravity = false
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.05
        manager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: OperationQueue.main){ data,error in
            let pit = self.manager.deviceMotion?.attitude.pitch // haut bas
            let roll = self.manager.deviceMotion?.attitude.roll // roulade
            
            let runDirection = CGVector(dx:CGFloat(Float(roll!)) , dy: CGFloat(Float(-1 * pit!)))
            guard let player = self.allPlayers[self.playerId] else {return}
            player.run(direction: runDirection, velocity: self.velocity!)
        }
        manager.startAccelerometerUpdates(to: OperationQueue.main){ data,error in
            self.velocity = CGVector(dx: (data?.acceleration.x)! * 360, dy: (data?.acceleration.y)! * 360)
        }
    }
    
    func createPlayer(playerId:String, number:Int){
        if let existingPlayer = self.allPlayers[playerId] {
            return
        }
        guard let position = playerPosition[number] else {return}
        self.allPlayers[playerId] = PlayerController()
        guard let player = self.allPlayers[playerId] else {return}
        player.setUpPlayerSprite(frame: frame, position: position ,withCallback: {
            sprite in
            addChild(sprite)
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let A = contact.bodyA
        let B = contact.bodyB
        
        print("A : \(A.categoryBitMask) \n B :\(B.categoryBitMask)")
        
        if ((A.categoryBitMask == 1 && B.categoryBitMask == 3) || (A.categoryBitMask == 3 && B.categoryBitMask == 1)){
            print("End Scene")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("sending player id")
        socket?.emit("player_login", ["id":self.playerId])
    }
    
    override func update(_ currentTime: TimeInterval) {
        // nothing
    }

}
