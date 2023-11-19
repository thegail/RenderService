//
//  makeDefaultScene.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/18/23.
//

import Foundation

func makeDefaultScene() -> RenderScene {
	var meshes: Array<any Mesh> = []
	meshes.append(Cube(scale: SIMD3(5, 5, 8), faces: [.up, .down, .back, .left, .right], inverted: true))
	meshes.append(Cube(position: SIMD3(1, 0, 1)))
	meshes.append(Cube(position: SIMD3(3, 0, 3), rotation: .pi / 6, scale: SIMD3(1, 3, 1)))
	
	return RenderScene(objects: meshes, camera: Camera(x: 2, y: 2, z: -1, pitch: 0, roll: 0, yaw: 0))
}
