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
	let lens: CameraType
	
	init(width: Int, height: Int, maxBounces: Int, camera: Camera, lensFile: ThickLensFile) {
		self.width = width
		self.height = height
		self.maxBounces = maxBounces
		self.camera = camera
		self.lens = .thickLens(CameraType.ThickLens(
			aperture: Float(lensFile.aperture),
			lensDistance: Float(lensFile.screenDistance),
			sampleScreenSize: SIMD2(Float(lensFile.screenWidth), Float(lensFile.screenHeight)),
			apertureDistance: Float(lensFile.apertureDistance),
			lenses: lensFile.lenses
		))
	}
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		var maxBounces: UInt32 = UInt32(self.maxBounces)
		var cameraType: UInt8 = self.lens.cameraTypeID
		var thinLensAperture: Float = self.lens.aperture
		var lensDistance: Float = self.lens.lensDistance
		var focusDistance: Float = self.lens.focusDistance
		var sampleScreenSize: SIMD2<Float> = self.lens.sampleScreenSize
		var apertureDistance: Float = self.lens.apertureDistance
		var lensCount = UInt32(self.lens.lenses.count)
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
		values.setConstantValue(&lensCount, type: .float, withName: "lens_count")
		values.setConstantValue(&cameraPosition, type: .float3, withName: "camera_position")
		values.setConstantValue(&cameraRight, type: .float3, withName: "camera_right")
		values.setConstantValue(&cameraUp, type: .float3, withName: "camera_up")
		values.setConstantValue(&cameraForward, type: .float3, withName: "camera_forward")
		
		return values
	}
}
