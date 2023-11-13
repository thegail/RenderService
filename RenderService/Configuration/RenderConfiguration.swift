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
	let textures: Array<TextureDescriptor>
	let lightModel: LightModel
	
	init(width: Int, height: Int, maxBounces: Int, camera: Camera, cameraType: CameraType, textures: TexturesFile, lightModel: LightModel) {
		self.width = width
		self.height = height
		self.maxBounces = maxBounces
		self.camera = camera
		self.cameraType = cameraType
		self.textures = textures
		self.lightModel = lightModel
	}
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		var maxBounces: UInt32 = UInt32(self.maxBounces)
		
		let constants = MTLFunctionConstantValues()
		constants.setConstantValue(&maxBounces, type: .uint, withName: "max_bounces")
		self.camera.setFunctionConstants(constants)
		self.cameraType.setFunctionConstants(constants)
		self.lightModel.setFunctionConstants(constants)
		
		return constants
	}
}
