//
//  AdaptableTexture.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import Metal

struct AdaptableTexture {
	private var device: MTLDevice
	private var inner: MTLTexture?
	
	init(device: MTLDevice) {
		self.device = device
		self.inner = nil
	}
	
	func getTexture(width: Int, height: Int) throws -> MTLTexture {
		guard let inner = self.inner else {
			return try self.makeTexture(width: width, height: height)
		}
		
		if inner.width != width || inner.height != height {
			return try self.makeTexture(width: width, height: height)
		}
		
		return inner
	}
	
	private func makeTexture(width: Int, height: Int) throws -> MTLTexture {
		let descriptor = MTLTextureDescriptor()
		descriptor.width = width
		descriptor.height = height
		descriptor.usage = [.shaderRead, .shaderWrite]
		descriptor.storageMode = .private
		descriptor.pixelFormat = .bgra8Unorm
		
		guard let texture = self.device.makeTexture(descriptor: descriptor) else {
			throw RenderError.targetTexture
		}
		
		return texture
	}
}
