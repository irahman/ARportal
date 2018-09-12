//
//  ViewController.swift
//  AR_Portal
//
//  Created by Irfan Rahman on 6/18/18.
//  Copyright © 2018 Irfan Rahman. All rights reserved.
//

import UIKit
import ARKit
//hhhh

class ViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet weak var planeDetected: UILabel!
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
   
        //room must be placed on a horizontal surface for the room to appear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGesture)//be weary of this!!, could be tapGestureRecognizer
        
    }
    
    
    //using objective-c, anytime you tap sceneview, this will get triggered
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        
        //do hit-test, see if touchLocation (tap location) is a horizontal location
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) //check if touchLocation matches a plane(.existingPlaneUsingExtent), the hitTestResult array will have one item rather than zero--?
        if !hitTestResult.isEmpty{ //if hitTest array is not empty, succesfull
            self.addPortal(hitTestResult: hitTestResult.first!)//were going to add our room
        } else {
            ////
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult){
        let portalScene = SCNScene(named: "Portal2.scnassets/Portal.scn") //we have to add portalfile in portal.xcassests file first
        
        //now we have to upload the node(the house) in the portal file
        let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false) //may need ! at end..
        
        //place our childNode(house) on the horizontal plane, the plane info is already in our hitTestResults if hitest worked (in the array)
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        
        //puts portal on exact plane position
        portalNode?.position = SCNVector3(planeXposition, planeYposition, planeZposition)
        self.sceneView.scene.rootNode.addChildNode(portalNode!)
        self.addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "+y")
        self.addPlane(nodeName: "bottom", portalNode: portalNode!, imageName: "-y")
        self.addWalls(nodeName: "backWall", portalNode: portalNode!, imageName: "-z2")
        self.addWalls(nodeName: "leftWall", portalNode: portalNode!, imageName: "-x")
        self.addWalls(nodeName: "rightWall", portalNode: portalNode!, imageName: "+x")
        self.addWalls(nodeName: "blue", portalNode: portalNode!, imageName: "-zright")
        self.addWalls(nodeName: "green", portalNode: portalNode!, imageName: "-zleft")
        
        //lets see 
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //whenever anchor info is added, the rendered func is triggered (in a background thread)
    //--> so make sure an UI updates happen on the main thread, such as line 43
    //anchor is just the position and size of the thing the anchor is positioned for in the real world
    //if anchor has plane info, it also contains horizontal flatsurface  info
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //checks to see if we detected a plane anchor
        guard anchor is ARPlaneAnchor else {return}
        
        DispatchQueue.main.async {
            //if anchor is plane anchor and we discover a horizontal flat surface, then unhide label
            self.planeDetected.isHidden = false
        }
        
        
        
        //then after 3 seconds, hide label again
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeDetected.isHidden = true
        }
    }
    
    
    //for adding walls
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String){
        //where child is roof,floor,etc. recursively entire folder tree. Note: Portal is actually under red carpet, has to search entire tree
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal2.scnassets/\(imageName).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false){
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    
    //adding pictures to each side of cube
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String){
        //where child is roof,floor,etc. recursively entire folder tree. Note: Portal is actually under red carpet, has to search entire tree
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal2.scnassets/\(imageName).png")
        child?.renderingOrder = 200
    
        
        
    }
    
    

}

