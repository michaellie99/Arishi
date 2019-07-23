//
//  ViewController.swift
//  ARDicee
//
//  Created by Kelvin Hadi Pratama on 10/07/19.
//  Copyright © 2019 Kelvin Hadi Pratama. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var nodeArray = [SCNNode]()
    
    var currentStep = 0
    // 0 initial
    // 1 rotate
    // 2 attach to chopstick
    // 3 move to soy sauce
    // 4 eat
    // 5 finish and back
    
    var currentTappedNode = SCNNode()
    
    
    var isSushiRotate = false
    
    var basePosition = SCNVector3(0.0, 0.0, 0.0)
    
    var contactOtherNode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //set the physics delegate
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if nodeArray.count < 2 {
                // Touch location on the screen
                let touchLocation = touch.location(in: sceneView)
                
                // Search for real world obj or AR Anchors, not sceneKit obj
                let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
                
                if let hitResult = results.first {
                    placeNodeOnPlane(hitResult: hitResult)
                }
                
            } else {
                
                // get what is touch in AR world
                let hits = self.sceneView.hitTest( touch.location(in: sceneView), options: nil)
                
                if let tappedNode = hits.first?.node {
                    currentTappedNode = tappedNode
                }
            }
        }
    }
    
    func placeNodeOnPlane(hitResult: ARHitTestResult) {
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/sushi.scn")
        
        // Check whether the diceScene already set up
        if let node = scene?.rootNode.childNode(withName: "sushi", recursively: false) {
            
            node.name = "sushi"
            node.scale = SCNVector3(0.5,0.5,0.5)
            node.position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + 0.01,
                hitResult.worldTransform.columns.3.z
            )
            basePosition = node.position
            
            nodeArray.append(node)
            
            sceneView.scene.rootNode.addChildNode(node)
            
        }
        
        // Create a new scene
        let shurikenScene = SCNScene(named: "art.scnassets/sumpit.scn")
        
        // Check whether the diceScene already set up
        if let node = shurikenScene?.rootNode.childNode(withName: "sumpit", recursively: false) {
            
            node.name = "chopstick"
            //                        shurikenNode.scale = SCNVector3(1.5,1.5,1.5)
            node.scale = SCNVector3(0.4, 0.3, 0.4)
            
            node.position = SCNVector3(
                hitResult.worldTransform.columns.3.x + 0.2,
                hitResult.worldTransform.columns.3.y + 0.01,
                hitResult.worldTransform.columns.3.z
            )
            
            nodeArray.append(node)
            sceneView.scene.rootNode.addChildNode(node)
            
        } else {
            print("failed")
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // Touch location on the screen
            let touchLocation = touch.location(in: sceneView)
            
            // Search for real world object that coressponding to the touch on the scene view
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            guard let result: ARHitTestResult = results.first else {
                return
            }
            
            let position = SCNVector3Make(
                result.worldTransform.columns.3.x,
                result.worldTransform.columns.3.y,
                result.worldTransform.columns.3.z)
            
            currentTappedNode.position = position
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTappedNode = SCNNode()
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("contact happened")
        
        
        // targeted node
        print("Node A: \(contact.nodeA.name ?? "empty") ")
        
        //        print("Node B: \(contact.nodeB.name ?? "empty") ")
        
        if contact.nodeA.physicsBody?.categoryBitMask == BodyType.sushi.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == BodyType.chopstick.rawValue {
            
            //            contactOtherNode = true
            
            print("chopstick is contacted by sushi")
            
            
        } else if  contact.nodeA.physicsBody?.categoryBitMask == BodyType.sushi.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == BodyType.basic.rawValue {
            
            //            contactOtherNode = true
            
            if contact.nodeA.name == "sushi" &&
                (contact.nodeB.name == "chopstick" || contact.nodeB.name == "sumpit_boundary" ){
                
                print("sushi is contacted by chopstick")
                
                // func rotate the sushi
                let sushi = contact.nodeA
                let chopstick = contact.nodeB
                
                if sushi.name == "sushi" {
                    
                    print("rotate the sushi")
                    
                    if currentStep == 0 {
                        rotateSushi(node: sushi)
                        updateStep()
                        
                        // make sushi follow chopsticks
                        sushi.removeFromParentNode()
                        
                        chopstick.addChildNode(sushi)
                        
                        // reposition the sushi according to the chopstick
                        print("Sushi position: \(sushi.position)\n")
                        //                        sushi.position = sushi.convertPosition(sushi.position, to: chopstick)
                        sushi.position = SCNVector3(0,-0.42,0.017)
                        sushi.scale = SCNVector3(3,3,3)
                        sushi.eulerAngles = SCNVector3(0,0,0)
                        
                        print("Sushi.position: \(sushi.position)\n")
                        
                        print("Chopstick posisi")
                        print(chopstick.position)
                        
                        print("sushi posisi")
                        print(sushi.position)
                    }
                }
            }
        }
        
        print("")
    }
    
    func updateStep() {
        currentStep += 1
    }
    
    func rotateSushi(node: SCNNode){
        let action = SCNAction.rotateTo(x: CGFloat(Double.pi / 2), y: CGFloat(Double.pi / 2), z: 0, duration: 0.5)
        node.runAction(action)
    }
    
    
    //    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
    //
    //        gesture.minimumNumberOfTouches = 1
    //
    //        let results = self.sceneView.hitTest(
    //            gesture.location(in: gesture.view),
    //            types: ARHitTestResult.ResultType.featurePoint)
    //
    //        guard let result: ARHitTestResult = results.first else {
    //            return
    //        }
    //
    //        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
    //
    //        if let tappedNode = hits.first?.node {
    //
    ////            if tappedNode.name != "sushi" {
    //
    //                let position = SCNVector3Make(
    //                    result.worldTransform.columns.3.x,
    //                    result.worldTransform.columns.3.y,
    //                    result.worldTransform.columns.3.z)
    //
    //                tappedNode.position = position
    ////            }
    //        }
    //    }
    
    //Detect real world surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/black_grid.png")
            plane.materials = [gridMaterial]
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.y)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            planeNode.geometry = plane
            planeNode.name = "surface"
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
    enum BodyType: Int {
        // power of 2
        case basic = 1
        case sushi = 2
        case chopstick = 4
        case soysauce = 8
    }
}
