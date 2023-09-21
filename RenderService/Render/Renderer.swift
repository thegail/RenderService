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
	let uniformsBuffer: MTLBuffer
	let accelerationStructure: MTLAccelerationStructure
	var uniforms: Uniforms
	
	init(device: RenderDevice, config: RenderConfiguration) throws {
		self.config = config
		self.device = device
		self.pipeline = try device.makeComputePipeline(constants: config.makeShaderConstants())
		self.targetTexture = try device.makeTargetTexture(width: config.width, height: config.height)
		let uniforms = Uniforms(camera: Camera(position: SIMD3(2, 2, -1), forward: SIMD3(0, 0, 1), right: SIMD3(1, 0, 0), up: SIMD3(0, 1, 0)), frame: 0)
		self.uniformsBuffer = try device.makeUniformsBuffer(data: uniforms)
		let (vertices, triangles) = generateTestScene()
		self.accelerationStructure = try device.makeAccelerationStructure(vertices: vertices, triangles: triangles)
		self.uniforms = uniforms
	}
	
	func draw() throws {
		self.uniforms.frame += 1
		var uniforms = self.uniforms
		self.uniformsBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<Uniforms>.stride)
		
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
		encoder.setBuffer(self.uniformsBuffer, offset: 0, index: 0)
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
