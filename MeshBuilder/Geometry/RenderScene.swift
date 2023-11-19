//
//  RenderScene.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/17/23.
//

import Foundation

class RenderScene {
	let objects: Array<any Mesh>
	let camera: Camera
	
	init(objects: Array<any Mesh>, camera: Camera) {
		self.objects = objects
		self.camera = camera
	}
	
	var vertices: Array<SIMD3<Float>> {
		self.objects.flatMap { $0.vertices }
	}
	
	var primitives: Array<UInt8> {
		self.objects.flatMap { $0.primitives }
	}
}
