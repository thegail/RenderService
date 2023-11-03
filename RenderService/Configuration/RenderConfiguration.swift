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
	let cameraType: CameraType
	
	init(width: Int, height: Int, maxBounces: Int, camera: Camera, cameraType: CameraType) {
		self.width = width
		self.height = height
		self.maxBounces = maxBounces
		self.camera = camera
		self.cameraType = cameraType
	}
	
	init(width: Int, height: Int, maxBounces: Int, camera: Camera, lensFile: LensFile) {
		let cameraType = CameraType.thickLens(CameraType.ThickLens(
			aperture: Float(lensFile.aperture),
			lensDistance: Float(lensFile.screenDistance),
			sampleScreenSize: SIMD2(Float(lensFile.screenWidth), Float(lensFile.screenHeight)),
			apertureDistance: Float(lensFile.apertureDistance),
			lenses: lensFile.lenses
		))
		self.init(width: width, height: height, maxBounces: maxBounces, camera: camera, cameraType: cameraType)
	}
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		var maxBounces: UInt32 = UInt32(self.maxBounces)
		
		let constants = MTLFunctionConstantValues()
		constants.setConstantValue(&maxBounces, type: .uint, withName: "max_bounces")
		self.camera.setFunctionConstants(constants)
		self.cameraType.setFunctionConstants(constants)
		
		return constants
	}
}
