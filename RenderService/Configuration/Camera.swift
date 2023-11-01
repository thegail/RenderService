//
//  Camera.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import Foundation

struct Camera {
	let position: SIMD3<Float>
	let pitch: Float
	let roll: Float
	let yaw: Float
	
	var pitchMatrix: simd_float3x3 {
		simd_float3x3(
			SIMD3(1, 0, 0),
			SIMD3(0, cos(self.pitch), sin(self.pitch)),
			SIMD3(0, -sin(self.pitch), cos(self.pitch))
		)
	}
	
	var rollMatrix: simd_float3x3 {
		simd_float3x3(
			SIMD3(cos(self.pitch), sin(self.pitch), 0),
			SIMD3(-sin(self.pitch), -cos(self.pitch), 0),
			SIMD3(0, 0, 1)
		)
	}
	
	var yawMatrix: simd_float3x3 {
		simd_float3x3(
			SIMD3(cos(self.pitch), 0, -sin(self.pitch)),
			SIMD3(0, 1, 0),
			SIMD3(sin(self.pitch), 0, cos(self.pitch))
		)
	}
	
	var rotationMatrix: simd_float3x3 {
		self.rollMatrix * self.pitchMatrix * self.yawMatrix
	}
}
