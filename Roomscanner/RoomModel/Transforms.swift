//
//  Transforms.swift
//  Roomscanner
//
//  Created by User on 1/8/2024.
//

import Foundation
import SceneKit

func rotateX(initial: simd_float4x4, degrees: Float) -> simd_float4x4 {
    var degrees = degrees/180 * Float.pi
    var initColumns: [simd_float3] = []
    initColumns.append(simd_make_float3(initial.columns.0))
    initColumns.append(simd_make_float3(initial.columns.1))
    initColumns.append(simd_make_float3(initial.columns.2))
    var smallMatrix = simd_float3x3(initColumns)
    var rotateMatrix = simd_float3x3(simd_make_float3(1, 0, 0), simd_make_float3(0, cos(degrees), -sin(degrees)), simd_make_float3(0, sin(degrees), cos(degrees)))
    var normalMatrix = smallMatrix*rotateMatrix//inverseMatrix.transpose
    var newColumns: [simd_float4] = []
    newColumns.append(simd_make_float4(normalMatrix.columns.0))
    newColumns.append(simd_make_float4(normalMatrix.columns.1))
    newColumns.append(simd_make_float4(normalMatrix.columns.2))
    newColumns.append(initial.columns.3)
    return simd_float4x4(newColumns)
}

func rotateY(initial: simd_float4x4, degrees: Float) -> simd_float4x4 {
    var degrees = degrees/180 * Float.pi
    var initColumns: [simd_float3] = []
    initColumns.append(simd_make_float3(initial.columns.0))
    initColumns.append(simd_make_float3(initial.columns.1))
    initColumns.append(simd_make_float3(initial.columns.2))
    var smallMatrix = simd_float3x3(initColumns)
    var rotateMatrix = simd_float3x3(simd_make_float3(cos(degrees), 0, sin(degrees)), simd_make_float3(0, 1, 0), simd_make_float3(-sin(degrees), 0, cos(degrees)))
    var normalMatrix = smallMatrix*rotateMatrix//inverseMatrix.transpose
    var newColumns: [simd_float4] = []
    newColumns.append(simd_make_float4(normalMatrix.columns.0))
    newColumns.append(simd_make_float4(normalMatrix.columns.1))
    newColumns.append(simd_make_float4(normalMatrix.columns.2))
    newColumns.append(initial.columns.3)
    return simd_float4x4(newColumns)
}

func parallel(inWall: simd_float4x4, paraWall: simd_float4x4) -> simd_float4x4{
    var initColumns: [simd_float3] = []
    initColumns.append(simd_make_float3(paraWall.columns.0))
    initColumns.append(simd_make_float3(paraWall.columns.1))
    initColumns.append(simd_make_float3(paraWall.columns.2))
    var newColumns: [simd_float4] = []
    newColumns.append(simd_make_float4(initColumns[0]))
    newColumns.append(simd_make_float4(initColumns[1]))
    newColumns.append(simd_make_float4(initColumns[2]))
    newColumns.append(inWall.columns.3)
    return simd_float4x4(newColumns)
}
