//
//  generateTestScene.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/21/23.
//

import Foundation

func generateTestScene(textures: Dictionary<UUID, UInt64>) -> (Array<SIMD3<Float>>, Array<Triangle>) {
	var cubes: Array<Cube> = []
	cubes.append(Cube(scale: SIMD3(5, 5, 8), faces: [.up, .down, .back, .left, .right], inverted: true))
	cubes.append(Cube(position: SIMD3(1, 0, 1), textureID: textures[UUID(uuidString: "BCF45004-CE0D-4EA0-8619-7A39BA536E72")!]!))
	cubes.append(Cube(position: SIMD3(3, 0, 3), rotation: .pi / 6, scale: SIMD3(1, 3, 1), textureID: textures[UUID(uuidString: "A6134345-2213-445F-B77B-ECC4EAC8E2EF")!]!))
	
	let vertices = cubes.map { $0.vertices }.reduce([], +)
	let triangles = cubes.map { $0.triangles }.reduce([], +)
	return (vertices, triangles)
}
