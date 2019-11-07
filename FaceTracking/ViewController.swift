//
//  ViewController.swift
//  FaceTracking
//
//  Created by Domo on 06/09/2019.
//  Copyright © 2019 Domenico Nicoli. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var outputView: UIView!
    @IBOutlet weak var outputLabel: UILabel!
    
    var facePoseResult = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking not available on this on this device model!")
        }
        
        outputView.layer.cornerRadius = 15
        sceneView.delegate = self
        sceneView.showsStatistics = true
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            facePoseAnalyzer(anchor: faceAnchor)
            
            DispatchQueue.main.async {
                self.outputLabel.text = self.facePoseResult
            }
            
        }
    }
    
    func facePoseAnalyzer(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let innerUp = anchor.blendShapes[.browInnerUp]
        let tongue = anchor.blendShapes[.tongueOut]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let jawOpen = anchor.blendShapes[.jawOpen]
        
        var newFacePoseResult = ""
    
        if ((jawOpen?.decimalValue ?? 0.0) + (innerUp?.decimalValue ?? 0.0)) > 0.6 {
            newFacePoseResult = "😧"
        }
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            newFacePoseResult = "😀"
        }
     
        if innerUp?.decimalValue ?? 0.0 > 0.8 {
            newFacePoseResult = "😳"
        }
        
        if tongue?.decimalValue ?? 0.0 > 0.08 {
            newFacePoseResult = "😛"
        }
        
        if cheekPuff?.decimalValue ?? 0.0 > 0.5 {
            newFacePoseResult = "🤢"
        }
        
        if eyeBlinkLeft?.decimalValue ?? 0.0 > 0.5 {
            newFacePoseResult = "😉"
        }
        
        if self.facePoseResult != newFacePoseResult {
            self.facePoseResult = newFacePoseResult
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
