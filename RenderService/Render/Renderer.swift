//
//  Renderer.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import Metal

class Renderer {
	let config: RenderConfiguration
	let device: RenderDevice
	let pipeline: MTLComputePipelineState
	let targetTexture: MTLTexture
	let uniformsBufer: MTLBuffer
	let accelerationStructure: MTLAccelerationStructure
	
	init(device: RenderDevice, config: RenderConfiguration) throws {
		self.config = config
		self.device = device
		self.pipeline = try device.makeComputePipeline(constants: config.makeShaderConstants())
		self.targetTexture = try device.makeTargetTexture(width: config.width, height: config.height)
		let uniforms = Uniforms(camera: Camera(position: SIMD3(2, 2, -1), forward: SIMD3(0, 0, 1), right: SIMD3(1, 0, 0), up: SIMD3(0, 1, 0)), frame: 0)
		self.uniformsBufer = try device.makeUniformsBuffer(data: uniforms)
		let (vertices, triangles) = generateTestScene()
		self.accelerationStructure = try device.makeAccelerationStructure(vertices: vertices, triangles: triangles)
	}
	
	func draw() throws {
		let commandBuffer = try self.device.makeCommandBuffer()
		guard let encoder = commandBuffer.makeComputeCommandEncoder() else {
			throw RenderError.commandEncoder
		}
		
		let gridSize = MTLSize(width: self.config.width, height: self.config.height, depth: 1)
		let groupSize = MTLSize(
			width: self.pipeline.threadExecutionWidth,
			height: self.pipeline.maxTotalThreadsPerThreadgroup / self.pipeline.threadExecutionWidth,
			depth: 1
		)
		
		encoder.setComputePipelineState(self.pipeline)
		encoder.setBuffer(self.uniformsBufer, offset: 0, index: 0)
		encoder.setAccelerationStructure(self.accelerationStructure, bufferIndex: 1)
		encoder.setTexture(self.targetTexture, index: 0)
		encoder.dispatchThreads(gridSize, threadsPerThreadgroup: groupSize)
		encoder.endEncoding()
		
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
	}
	
	func export() throws -> Data {
		let texture = try self.device.makeInspectionTexture(width: self.config.width, height: self.config.height)
		let commandBuffer = try self.device.makeCommandBuffer()
		guard let encoder = commandBuffer.makeBlitCommandEncoder() else {
			throw RenderError.blitEncoder
		}
		
		encoder.copy(from: self.targetTexture, to: texture)
		encoder.endEncoding()
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
		
		let bytesPerRow = self.config.width * 4
		let imageSize = bytesPerRow * self.config.height
		var data = Array<UInt8>(repeating: 0, count: imageSize)
		texture.getBytes(
			&data,
			bytesPerRow: bytesPerRow,
			from: MTLRegion(
				origin: MTLOrigin(x: 0, y: 0, z: 0),
				size: MTLSize(width: self.config.width, height: self.config.height, depth: 1)
			),
			mipmapLevel: 0
		)
		
		return Data(data)
	}
}
