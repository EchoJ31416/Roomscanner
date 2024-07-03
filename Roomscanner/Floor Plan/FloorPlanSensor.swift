//
//  FloorPlanSensor.swift
//  Roomscanner
//
//  Created by User on 2/7/2024.
//

import SpriteKit
import RoomPlan

class FloorPlanSensor: SKNode {
    
    private let capturedSensor: simd_float4
    
    // MARK: - Init
    
    init(capturedSensor: simd_float4) {
        self.capturedSensor = capturedSensor
        
        super.init()
        
        // Set the object's position using the transform matrix
        let objectPositionX = -CGFloat(capturedSensor.x) * scalingFactor
        let objectPositionY = CGFloat(capturedSensor.z) * scalingFactor
        self.position = CGPoint(x: objectPositionX, y: objectPositionY)
        
        // Set the object's zRotation using the transform matrix
        self.zRotation = 0.0//-CGFloat(capturedObject.transform.eulerAngles.z - capturedObject.transform.eulerAngles.y)
        
        drawSensor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    
    private func drawSensor() {
        // Calculate the object's dimensions
        /*let objectWidth = CGFloat(capturedObject.dimensions.x) * scalingFactor
        let objectHeight = CGFloat(capturedObject.dimensions.z) * scalingFactor
        
        // Create the object's rectangle
        let objectRect = CGRect(
            x: -objectWidth / 2,
            y: -objectHeight / 2,
            width: objectWidth,
            height: objectHeight
        )*/
        
        // A shape to fill the object
        let sensorShape = SKShapeNode(circleOfRadius: 10.0)
        sensorShape.strokeColor = .clear
        sensorShape.fillColor = floorPlanSurfaceColor
        sensorShape.alpha = 0.3
        sensorShape.zPosition = objectZPosition
        
        // And another shape for the outline
        let sensorOutlineShape = SKShapeNode(circleOfRadius: 10.1)
        sensorOutlineShape.strokeColor = floorPlanSurfaceColor
        sensorOutlineShape.lineWidth = 4.0
        sensorOutlineShape.lineJoin = .miter
        sensorOutlineShape.zPosition = objectOutlineZPosition
                
        // Add both shapes to the node
        addChild(sensorShape)
        addChild(sensorOutlineShape)
    }
    
}
