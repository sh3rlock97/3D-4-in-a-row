//
//  ViewController.swift
//  3D_Game
//
//  Created by Marino Schmid on 08.10.18.
//  Copyright © 2018 Marino Schmid. All rights reserved.
//

import UIKit
import SceneKit


extension SCNScene {

  
}

class gameNode : SCNNode {
    var player = true
    var grid : [SCNNode] = []
    var cameraNode = SCNCamera()
    var rotated : Float = 0;
    
    var fields : [[[Int]]] = []
    func setup() {
        for z in 0..<4 {
            fields.append([])
            for y in 0..<4 {
                fields[z].append([])
                for _ in 0..<4 {
                    fields[z][y].append(-1)
                }
            }
        }
        print(fields)
        for i in 0..<16 {
            let x : Float = Float(i%4)-1.5
            let y : Float = Float(i/4)-1.5
            let box = SCNBox(width: 9.5, height: 9.5, length: 9.5, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1)
            let boxnode = SCNNode(geometry: box)
            boxnode.position = SCNVector3(boxnode.position.x+10*x, boxnode.position.y+10*y, boxnode.position.z)
            self.addChildNode(boxnode)
            grid.append(boxnode)
            boxnode.name = "\(i%4) \(i/4) -1";
        }
        self.eulerAngles = SCNVector3(Double.pi/2+1, 0, 0)
        rotated = 0;
        
        
        rot()
    }
    
    @objc func rot() {
//        let pos = SCNVector3(self.position.x,self.position.y,self.position.z)
//        for node in grid {
//            node.rotate(by: SCNQuaternion(0,0.02,0,1), aroundTarget: pos)
//        }
//        self.eulerAngles.y += 0.02
//        if(self.eulerAngles.y.truncatingRemainder(dividingBy: Float.pi*2) < Float.pi) {
//            self.eulerAngles.x -= 0.005
//        } else {
//            self.eulerAngles.x += 0.005
//        }

//        if(self.eulerAngles.y.truncatingRemainder(dividingBy: Float.pi*2) > Float.pi/2 && self.eulerAngles.y.truncatingRemainder(dividingBy: Float.pi*2) < Float.pi/2*3) {
//            self.eulerAngles.z -= 0.005
//
//        } else {
//            self.eulerAngles.z += 0.005
//
//        }
        
       // self.rotate(by: SCNQuaternion(x: 0, y: 0.1, z: 0, w: 1), aroundTarget: SCNVector3(self.eulerAngles.x,self.eulerAngles.y,self.eulerAngles.z))
        
        
        
        //let timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.03),
                                         //target: self, selector: #selector(gameNode.rot), userInfo: nil, repeats: false)
    }
    
    func rota(_ by : CGFloat) {
        let orientation = self.orientation
        var glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        
        // Rotate around Z axis
        rotated += Float(by)
        let multiplier = GLKQuaternionMakeWithAngleAndAxis(Float(by), 0, 0, 1)
        glQuaternion = GLKQuaternionMultiply(glQuaternion, multiplier)
        
        self.orientation = SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
    }
    func rotb(_ by : CGFloat) {
        self.rotate(by: SCNQuaternion(by, 0, 0, 1), aroundTarget: self.position)
    }
    
    func add(_ hitnode : SCNNode) {
        print(hitnode.name)
        var xyz = (hitnode.name)!.split(separator: " ")
        print(xyz)
        var x = Int(xyz[0])!
        var y = Int(xyz[1])!
        var z = Int(xyz[2])!+1
        if(z <= 3 && fields[z][y][x] == -1) {
            fields[z][y][x] = player ? 1 : 0
        } else {
            return;
        }

        let heightNewNode : Float = 7;
        let box = SCNBox(width: CGFloat(heightNewNode)-1, height: CGFloat(heightNewNode)-1, length: CGFloat(heightNewNode)-1, chamferRadius: 1)
        if(player) {
            box.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0.9)
        } else {
            box.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0, alpha: 0.9)
        }
        let boxnode = SCNNode(geometry: box)
        boxnode.name = "\(x) \(y) \(z)"
        let heightHitnode = (hitnode.geometry?.boundingBox.max.z ?? 0)-(hitnode.geometry?.boundingBox.min.z ?? 0)
        let height = (heightNewNode + heightHitnode)/2
        boxnode.position = SCNVector3(hitnode.position.x, hitnode.position.y, hitnode.position.z-height)
        self.addChildNode(boxnode)
        player = !player
    }
    
}
class ViewController: UIViewController {

    @IBOutlet weak var scnview: SCNView!
    var scene : SCNScene = SCNScene()
    
    @IBAction func hit(_ sender: UITapGestureRecognizer) {
        
        // check what nodes are tapped
        var p = sender.location(in: scnview)
        var hitResults = scnview.hitTest(p, options: nil)
        if hitResults.count > 0
        {
            
            var hitnode = (hitResults.first)!.node
            var normal = (hitResults.first)!.localNormal
            print("\nName of node hit is \(hitnode.name)")
            print(normal)
            if round(normal.z) == -1 {
                print("TOP?")
                node.add(hitnode)
            }
            
            //var indexvalue = hitResults.first?.faceIndex
            //print(indexvalue)
        }
        
    }
    let node = gameNode();
    
    @IBAction func rotate(_ sender: Any) {
    }
    
    var touchx : CGFloat = 0;
    var touchy : CGFloat = 0;
    
    var altMulti : SCNVector3 = SCNVector3(10,10,10)
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        print("!!!!!!!")
        let multi = Float(sender.scale);
        print("XYZ \(multi)")
    
        
        if(sender.state == .began) {
            print(node.scale)
            altMulti = node.scale
        }

        node.scale = altMulti
        
        node.scale.x *= multi
        node.scale.z *= multi
        node.scale.y *= multi
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            node.rota((touchx - touch.location(in: self.view).x)/200)
            node.rotb((touch.location(in: self.view).y)/200 - touchy/200)
            print("A: \((touchx - touch.location(in: self.view).x)/200)")
            print((touch.location(in: self.view).y)/200)
            print(touchy/200)
            print("B: \((touch.location(in: self.view).y)/200 - touchy/200)")
            touchx = touch.location(in: self.view).x
            touchy = touch.location(in: self.view).y
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            touchx = touch.location(in: self.view).x
            touchy = touch.location(in: self.view).y
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = SCNScene()
        node.setup()
        scene.rootNode.addChildNode(node)
        scnview.autoenablesDefaultLighting = true
        scnview.scene = scene
        scnview.pointOfView?.orientation = SCNVector4(0,0,-100,0.5)
        // Do any additional setup after loading the view, typically from a nib.
    }


}

