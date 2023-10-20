//
//  RenderConfiguration.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import Metal

struct RenderConfiguration {
	let width: Int
	let height: Int
	let maxBounces: Int
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		var maxBounces: UInt32 = UInt32(self.maxBounces)
		var cameraType: UInt8 = 2
		var thinLensAperture: Float = 0.5
		var lensDistance: Float = 4
		var focusDistance: Float = 4
		let values = MTLFunctionConstantValues()
		values.setConstantValue(&maxBounces, type: .uint, withName: "max_bounces")
		values.setConstantValue(&cameraType, type: .uchar, withName: "camera_type")
		values.setConstantValue(&thinLensAperture, type: .float, withName: "camera_aperture")
		values.setConstantValue(&lensDistance, type: .float, withName: "lens_distance")
		values.setConstantValue(&focusDistance, type: .float, withName: "focus_distance")
		
		return values
	}
}
