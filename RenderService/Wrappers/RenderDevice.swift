//
//  RenderDevice.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import Metal

class RenderDevice {
	private let inner: MTLDevice
	private let commandQueue: MTLCommandQueue
	
	init() throws {
		guard let device = MTLCreateSystemDefaultDevice() else {
			throw RenderError.device
		}
		guard let commandQueue = device.makeCommandQueue() else {
			throw RenderError.commandQueue
		}
		
		self.inner = device
		self.commandQueue = commandQueue
	}
	
	init(deviceID: UInt64) throws {
		let devices = MTLCopyAllDevices()
		guard let device = devices.first(where: { $0.registryID == deviceID }) else {
			throw RenderError.device
		}
		guard let commandQueue = device.makeCommandQueue() else {
			throw RenderError.commandQueue
		}
		
		self.inner = device
		self.commandQueue = commandQueue
	}
	
	static func listDevices() -> Array<(UInt64, String)> {
		let devices = MTLCopyAllDevices()
		return devices.map { device in
			let id = device.registryID
			let description = device.description
			return (id, description)
		}
	}
	
	func makeCommandBuffer() throws -> MTLCommandBuffer {
		guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
			throw RenderError.commandBuffer
		}
		
		return commandBuffer
	}
	
	func makeComputePipeline() throws -> MTLComputePipelineState {
		guard let library = self.inner.makeDefaultLibrary() else {
			throw RenderError.library
		}
		
		let state: MTLComputePipelineState
		do {
			let function = try library.makeFunction(name: "render_image", constantValues: MTLFunctionConstantValues())
			state = try self.inner.makeComputePipelineState(function: function)
		} catch {
			throw RenderError.computePipeline
		}
		
		return state
	}
	
	func makeTargetTexture(width: Int, height: Int) throws -> MTLTexture {
		let descriptor = MTLTextureDescriptor()
		descriptor.width = width
		descriptor.height = height
		descriptor.usage = [.shaderRead, .shaderWrite]
		descriptor.storageMode = .private
		descriptor.pixelFormat = .bgra8Unorm
		
		guard let texture = self.inner.makeTexture(descriptor: descriptor) else {
			throw RenderError.targetTexture
		}
		
		return texture
	}
	
	func makeUniformsBuffer(data: Uniforms) throws -> MTLBuffer {
		var data = data
		let buffer = self.inner.makeBuffer(
			bytes: &data,
			length: MemoryLayout<Uniforms>.stride,
			options: .cpuCacheModeWriteCombined
		)
		guard let buffer = buffer else {
			throw RenderError.uniformsBuffer
		}
		
		return buffer
	}
}
