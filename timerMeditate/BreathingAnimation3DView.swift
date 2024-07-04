//
//  BreathingAnimation3DView.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 21/5/2024.
//
import SwiftUI
import RealityKit

struct BreathingAnimation3DView: View {
    var body: some View {
        RealityView { content in
            // Create a parent entity for the breathing animation
            let parentNode = Entity()

            // Add spheres for the breathing animation
            let sphereRadius: Float = 0.05
            let sphereDistance: Float = 0.2
            var sphereEntities: [ModelEntity] = []
            for i in 0...2 {
                let sphereEntity = generateSphereEntity(radius: sphereRadius)
                sphereEntity.position.y = Float(i) * sphereDistance
                parentNode.addChild(sphereEntity)
                sphereEntities.append(sphereEntity)
            }

            // Apply breathing animation
            applyBreathingAnimation(to: sphereEntities)

            // Add the parent node to the scene content
            content.add(parentNode)
        }
    }

    private func generateSphereEntity(radius: Float) -> ModelEntity {
        let sphereMesh = MeshResource.generateSphere(radius: radius)
        let sphereModel = ModelEntity(mesh: sphereMesh)
        return sphereModel
    }

    private func applyBreathingAnimation(to entities: [ModelEntity]) {
        // Define breathing animation parameters
        let scaleUp: SIMD3<Float> = [1.2, 1.2, 1.2]
        let scaleDown: SIMD3<Float> = [0.8, 0.8, 0.8]
        let animationDuration: TimeInterval = 2.0

        // Apply animation to each entity
        for entity in entities {
            // Scale up animation
            entity.move(to: .init(scale: scaleUp), relativeTo: nil, duration: animationDuration, timingFunction: .easeInOut)

            // Scale down animation
            entity.move(to: .init(scale: scaleDown), relativeTo: nil, duration: animationDuration, timingFunction: .easeInOut, completion: {
                // Repeat the sequence indefinitely
                self.applyBreathingAnimation(to: [entity]) // Recursive call
            })
        }
    }
}

#Preview {
    BreathingAnimation3DView()
}
