//
//  GameScene.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/17/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import SpriteKit
import SceneKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var emitterNode : SKEmitterNode?
    
    private var lightEmitterNode : SKEmitterNode?
    
    private var mouthEmitterNodes : [SKEmitterNode] = [SKEmitterNode]()
    
    private var leftEarEmitterNodes: [SKEmitterNode] = [SKEmitterNode]()
    private var rightEarEmitterNodes: [SKEmitterNode] = [SKEmitterNode]()
    
    private var leftEyeEmitterNodes: [SKEmitterNode] = [SKEmitterNode]()
    private var rightEyeEmitterNodes: [SKEmitterNode] = [SKEmitterNode]()
    
    private var leftCheekImageView: UIImageView = UIImageView()
    private var rightCheekImageView: UIImageView = UIImageView()
    
    private var playSound: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.createLightEmitterNode()
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointDetected(atPoint pos: CGPoint) {
        if let node = self.childNode(withName: "sakura_1") {
            node.position = pos
        } else {
            if let n = self.emitterNode {
                n.position = pos
                self.addChild(n)
            }
        }
    }
    
    func pointDetected(atPoint pos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if let node = self.childNode(withName: "left_lightnode") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "right_lightnode") {
            node.removeFromParent()
        }
        
        if let node = self.childNode(withName: "lightnode") {
            node.position = pos
            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "lightnode"
                n.position = pos
                n.emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        for i in 1...6 {
            if let leftNode = self.childNode(withName: "le_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "re_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "ly_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "ry_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.position = pos
                // MARK: - change emitter direction
                (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                self.createMouthEmitterNodes()
                self.mouthEmitterNodes[i - 1].position = pos
                self.addChild(self.mouthEmitterNodes[i - 1])
            }
        }
        
    }
    
    func earsPointDetected(lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if let node = self.childNode(withName: "lightnode") {
            node.removeFromParent()
        }
        
        if let node = self.childNode(withName: "left_lightnode") {
            node.position = lpos
            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "left_lightnode"
                n.position = lpos
                n.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "right_lightnode") {
            node.position = rpos
            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "right_lightnode"
                n.position = rpos
                n.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        for i in 1...6 {
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "ly_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "ry_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            // left ear node
            if let leftNode = self.childNode(withName: "le_sakura_\(i)") {
                leftNode.position = lpos
                (leftNode as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                self.createEarsEmitterNodes()
                self.leftEarEmitterNodes[i - 1].position = lpos
                self.addChild(self.leftEarEmitterNodes[i - 1])
            }
            // right ear node
            if let rightNode = self.childNode(withName: "re_sakura_\(i)") {
                rightNode.position = rpos
                (rightNode as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                self.createEarsEmitterNodes()
                self.rightEarEmitterNodes[i - 1].position = rpos
                self.addChild(self.rightEarEmitterNodes[i - 1])
            }
        }
    }
    
    func eyesPointDetected(lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if let node = self.childNode(withName: "lightnode") {
            node.removeFromParent()
        }
        
        if let node = self.childNode(withName: "left_lightnode") {
            node.position = lpos
            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "left_lightnode"
                n.position = lpos
                n.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "right_lightnode") {
            node.position = rpos
            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "right_lightnode"
                n.position = rpos
                n.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        for i in 1...6 {
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "le_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "re_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            // left eye node
            if let leftNode = self.childNode(withName: "ly_sakura_\(i)") {
                leftNode.position = lpos
                (leftNode as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                self.createEyesEmitterNodes()
                self.leftEyeEmitterNodes[i - 1].position = lpos
                self.addChild(self.leftEyeEmitterNodes[i - 1])
            }
            // right eye node
            if let rightNode = self.childNode(withName: "ry_sakura_\(i)") {
                rightNode.position = rpos
                (rightNode as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                self.createEyesEmitterNodes()
                self.rightEyeEmitterNodes[i - 1].position = rpos
                self.addChild(self.rightEyeEmitterNodes[i - 1])
            }
        }
    }
    
    func cheeksDetected(faceRect: CGRect, leftCheekPoint: CGPoint, rightCheekPoint: CGPoint) {
        self.leftCheekImageView.center = leftCheekPoint
        self.rightCheekImageView.center = rightCheekPoint
    }
    
    func noPointDetected() {
        // light node
        if let node = self.childNode(withName: "lightnode") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "left_lightnode") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "right_lightnode") {
            node.removeFromParent()
        }
        
        for i in 1...6 {
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "le_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "re_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "ly_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "ry_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            
        }
    }
    
    func calculatedEmissionAngle(y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        
        if (radY < -0.15) {
            if (radY < -0.3) {
                return CGFloat(180.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else if (radY > 0.15) {
            if (radY > 0.3) {
                return CGFloat(0.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else {
            if (radZ < 0) {
                
            } else {
                
            }
            return CGFloat(270.0 * .pi / 180.0) + radZ
        }
    }
    
    func calculatedEyesEmissionAngle(leftEye: Bool, y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        
        if (radY < -0.15) {
            if (radY < -0.3) {
                return CGFloat(180.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else if (radY > 0.15) {
            if (radY > 0.3) {
                return CGFloat(0.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else {
            if (radZ < 0) {
                
            } else {
                
            }
            return leftEye ? CGFloat(260.0 * .pi / 180.0) + radZ : CGFloat(280.0 * .pi / 180.0) + radZ
        }
    }
    
    func calculatedEarsEmissionAngle(leftEar: Bool, y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        return leftEar ? CGFloat(180.0 * .pi / 180.0) + radZ : CGFloat(0.0 * .pi / 180.0) + radZ
    }
    
    func createMouthEmitterNodes() {
        self.mouthEmitterNodes.removeAll()
        self.mouthEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createMouthEmitterNodes()
    }
    
    func createEyesEmitterNodes() {
        self.leftEyeEmitterNodes.removeAll()
        self.leftEyeEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createLeftEyeEmitterNodes()
        self.rightEyeEmitterNodes.removeAll()
        self.rightEyeEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createRightEyeEmitterNodes()
    }
    
    func createEarsEmitterNodes() {
        self.leftEarEmitterNodes.removeAll()
        self.leftEarEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createLeftEarEmitterNodes()
        self.rightEarEmitterNodes.removeAll()
        self.rightEarEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createRightEarEmitterNodes()
    }
    
    func createLightEmitterNode() {
        self.lightEmitterNode = SKEmitterNode(fileNamed: "LightParticle")
    }
    
    /*
    func touchDown(atPoint pos : CGPoint) {
        print("touchDown at \(pos)")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    */
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
