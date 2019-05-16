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
            print("A Player logged in")
            print(data)
            
            guard let dict = data[0] as? NSDictionary else {return}
            
            for (_, player) in dict {
                guard let p = player as? NSDictionary else { continue }
                guard let id = p["id"] else { continue }
                guard let number = p["number"] else { continue }
                
                self.createPlayer(playerId: id as! String, number: number as! Int)
            }
        })
        
        socket?.on("player_disconnected", callback: { data, ack in
            print("someone disconnected")
            guard let player = data[0] as? NSDictionary else { return }
            guard let id = player["id"] as? String else { return }
            
            guard let currentPlayer = self.allPlayers[id] else { return }
            currentPlayer.sprite.removeFromParent()
            
            // Removing disconnected player's sprite
            self.allPlayers[id] = nil
        })

        socket?.on("some_player_move", callback: { data, ack  in
            print("someone move")
            guard let dict = data[0] as? NSDictionary else {return}
            
            guard let id = dict["id"] as? String else {return}
            if id == self.playerId {return}
            print("someone moved")
            guard let x = dict["x"] as? Double else {return}
            guard let y = dict["y"] as? Double else {return}
            guard let velocityX = dict["velocityX"] as? Double else { return }
            guard let velocityY = dict["velocityY"] as? Double else { return }
            
            let velocity = CGVector(dx: velocityX, dy: velocityY)
            guard let player = self.allPlayers[id] else { return }
            
            let direction = CGVector(dx: x, dy: y)
            player.run(direction: direction, velocity: velocity)
        })
        
        socket?.on("game_finished", callback: { data, ack in
            guard let winner = data[0] as? NSDictionary else { return }
            print(winner)
            // Les joueurs sont triés par ordre d'arrivée
            self.finishGame(player: winner)
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
            // TODO: Le calcul à la réception n'est pas bon car il s'agit d'un vecteur et non d'un POINT dans l'espace, il faut revoir notre calcul
            self.socket?.emit("player_move", ["id":self.playerId,"x":runDirection.dx,"y":runDirection.dy, "velocityX": self.velocity?.dx, "velocityY": self.velocity?.dy])
        }
        manager.startAccelerometerUpdates(to: OperationQueue.main){ data,error in
            self.velocity = CGVector(dx: (data?.acceleration.x)! * 360, dy: (data?.acceleration.y)! * 360)
        }
    }
    
    func createPlayer(playerId:String, number:Int){
        if let existingPlayer = self.allPlayers[playerId] {
            return
        }
        self.allPlayers[playerId] = PlayerController(frame: frame, playerNumber: number , callback: {
            sprite in
            addChild(sprite)
        })
        
        // TODO: Remove the following content -> Used to dev on a simulator as CoreMotion does not work...        
//        let runDirection = CGVector(dx: 1 , dy: -1)
//        guard let player = self.allPlayers[self.playerId] else {return}
//        let velocit = CGVector(dx: 0.2, dy: 0.2)
//        player.run(direction: runDirection, velocity: velocit)
//        self.socket?.emit("player_move", ["id":self.playerId,"x":runDirection.dx,"y":runDirection.dy, "velocityX": velocit.dx, "velocityY": velocit.dy])
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let A = contact.bodyA
        let B = contact.bodyB
        
        print("A : \(A.categoryBitMask) \n B :\(B.categoryBitMask)")
        
        if ((A.categoryBitMask > 100 && B.categoryBitMask == 3) || (A.categoryBitMask == 3 && B.categoryBitMask > 100)){
            print("End Scene")
            if A.categoryBitMask > 100 {
                contact.bodyA.node?.physicsBody = nil
            } else {
                contact.bodyB.node?.physicsBody = nil
            }
            let secondScene = ModeScene(fileNamed: "ModeScene")
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            secondScene?.scaleMode = .aspectFill
            scene?.view?.presentScene(secondScene!, transition: transition)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("sending player id")
        socket?.emit("player_login", ["id":self.playerId])
    }
    
    override func update(_ currentTime: TimeInterval) {
        // nothing
    }
    
    func finishGame(player: NSDictionary) {
        // Animate user
        guard let id = player["id"] as? String else { return }
        guard let number = player["number"] as? Int else { return }
        guard let winner = allPlayers[id] else { return }
        
        // Place Winner's sprite in the middle of the screen
        winner.sprite.size = CGSize(width: 250, height: 250)
        winner.sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        // Stop Running Animation
        winner.sprite.removeAllActions()
        
        //
        let label = SKLabelNode(fontNamed: "KirbyNoKiraKizzuBRK")
        label.text = "The Winner is: Player \(number)"
        label.fontSize = 50.0
        label.position = CGPoint(x: frame.midX, y: frame.midY + 130.0)
        addChild(label)
    }

}
