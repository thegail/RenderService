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
	let camera: Camera
	let lens: Lens
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		var maxBounces: UInt32 = UInt32(self.maxBounces)
		var cameraType: UInt8 = self.lens.cameraTypeID
		var thinLensAperture: Float = self.lens.aperture
		var lensDistance: Float = self.lens.lensDistance
		var focusDistance: Float = self.lens.focusDistance
		var sampleScreenSize: SIMD2<Float> = self.lens.sampleScreenSize
		var apertureDistance: Float = self.lens.apertureDistance
		var lensThickness: Float = self.lens.thickness
		var cameraPosition = self.camera.position
		let cameraMatrix = self.camera.rotationMatrix
		var cameraRight = cameraMatrix.columns.0
		var cameraUp = cameraMatrix.columns.1
		var cameraForward = cameraMatrix.columns.2
		let values = MTLFunctionConstantValues()
		values.setConstantValue(&maxBounces, type: .uint, withName: "max_bounces")
		values.setConstantValue(&cameraType, type: .uchar, withName: "camera_type")
		values.setConstantValue(&thinLensAperture, type: .float, withName: "camera_aperture")
		values.setConstantValue(&lensDistance, type: .float, withName: "lens_distance")
		values.setConstantValue(&focusDistance, type: .float, withName: "focus_distance")
		values.setConstantValue(&sampleScreenSize, type: .float2, withName: "sample_screen_size")
		values.setConstantValue(&apertureDistance, type: .float, withName: "aperture_distance")
		values.setConstantValue(&lensThickness, type: .float, withName: "lens_thickness")
		values.setConstantValue(&cameraPosition, type: .float3, withName: "camera_position")
		values.setConstantValue(&cameraRight, type: .float3, withName: "camera_right")
		values.setConstantValue(&cameraUp, type: .float3, withName: "camera_up")
		values.setConstantValue(&cameraForward, type: .float3, withName: "camera_forward")
		
		return values
	}
}
