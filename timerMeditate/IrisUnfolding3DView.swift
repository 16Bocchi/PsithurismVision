import SwiftUI
import SceneKit

struct IrisUnfolding3DView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()
        sceneView.scene = scene
        
        let irisNode = createIrisNode()
        scene.rootNode.addChildNode(irisNode)
        
        animateIrisUnfolding(node: irisNode)
        
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func createIrisNode() -> SCNNode {
        let irisGeometry = SCNSphere(radius: 0.1)
        irisGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        let irisNode = SCNNode(geometry: irisGeometry)
        irisNode.scale = SCNVector3(0, 0, 0) // Start with a closed iris
        return irisNode
    }

    private func animateIrisUnfolding(node: SCNNode) {
        let scaleAction = SCNAction.scale(to: 1.0, duration: 2.0)
        scaleAction.timingMode = .easeInEaseOut
        
        let closeAction = SCNAction.scale(to: 0.0, duration: 2.0)
        closeAction.timingMode = .easeInEaseOut
        
        let sequence = SCNAction.sequence([scaleAction, closeAction])
        let repeatAction = SCNAction.repeatForever(sequence)
        
        node.runAction(repeatAction)
    }
}


#Preview {
    IrisUnfolding3DView()
}
