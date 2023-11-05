//
//  generateTestScene.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/21/23.
//

import Foundation

func generateTestScene(textureIDs: Array<UInt64>) -> (Array<SIMD3<Float>>, Array<Triangle>) {
	var cubes: Array<Cube> = []
	cubes.append(Cube(scale: SIMD3(5, 5, 8), faces: [.up, .down, .back, .left, .right], inverted: true))
	cubes.append(Cube(position: SIMD3(1, 0, 1), textureID: textureIDs[2]))
	cubes.append(Cube(position: SIMD3(3, 0, 3), rotation: .pi / 6, scale: SIMD3(1, 3, 1), textureID: textureIDs[0]))
	
	let vertices = cubes.map { $0.vertices }.reduce([], +)
	let triangles = cubes.map { $0.triangles }.reduce([], +)
	return (vertices, triangles)
}
