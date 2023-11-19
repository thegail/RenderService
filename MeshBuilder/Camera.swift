//
//  struct Camera.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/17/23.
//

import Foundation
import simd

struct Camera {
	let x: Double
	let y: Double
	let z: Double
	let pitch: Double
	let roll: Double
	let yaw: Double
	
	var position: SIMD3<Float> {
		return SIMD3(Float(self.x), Float(self.y), Float(self.z))
	}
	
	var translationMatrix: simd_float4x4 {
		return simd_float4x4(
			SIMD4(1, 0, 0, 0),
			SIMD4(0, 1, 0, 0),
			SIMD4(0, 0, 1, 0),
			SIMD4(Float(self.x), Float(self.y), Float(self.z), 1)
		)
	}
	
	var pitchMatrix: simd_float4x4 {
		return simd_float4x4(
			SIMD4(1, 0, 0, 0),
			SIMD4(0, cos(Float(self.pitch)), sin(Float(self.pitch)), 0),
			SIMD4(0, -sin(Float(self.pitch)), cos(Float(self.pitch)), 0),
			SIMD4(0, 0, 0, 1)
		)
	}
	
	var rollMatrix: simd_float4x4 {
		return simd_float4x4(
			SIMD4(cos(Float(self.roll)), sin(Float(self.roll)), 0, 0),
			SIMD4(-sin(Float(self.roll)), cos(Float(self.roll)), 0, 0),
			SIMD4(0, 0, 1, 0),
			SIMD4(0, 0, 0, 1)
		)
	}
	
	var yawMatrix: simd_float4x4 {
		return simd_float4x4(
			SIMD4(cos(Float(self.yaw)), 0, -sin(Float(self.yaw)), 0),
			SIMD4(0, 1, 0, 0),
			SIMD4(sin(Float(self.yaw)), 0, cos(Float(self.yaw)), 0),
			SIMD4(0, 0, 0, 1)
		)
	}
	
	var perspectiveMatrix: simd_float4x4 {
		let fov: Float = 0.5 * .pi
		let near: Float = 0.04
		let far: Float = 2
		let f: Float = 1 / tan(fov / 2)
		let aspectRatio: Float = 1
		return simd_float4x4(
			SIMD4(f / aspectRatio, 0, 0, 0),
			SIMD4(0, f, 0, 0),
			SIMD4(0, 0, (far + near) / (near - far), -1),
			SIMD4(0, 0, 2 * far * near / (near - far), 0)
		)
	}
	
	var transformationMatrix: simd_float4x4 {
		self.perspectiveMatrix * self.rollMatrix * self.pitchMatrix * self.yawMatrix * self.translationMatrix
	}
}
