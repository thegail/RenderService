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
	
	init(device: RenderDevice, config: RenderConfiguration) throws {
		self.config = config
		self.device = device
		self.pipeline = try device.makeComputePipeline()
		self.targetTexture = try device.makeTargetTexture(width: config.width, height: config.height)
		self.uniformsBufer = try device.makeUniformsBuffer(data: Uniforms())
	}
	
	func draw() throws {
		let commandBuffer = try device.makeCommandBuffer()
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
		encoder.setTexture(self.targetTexture, index: 0)
		encoder.dispatchThreads(gridSize, threadsPerThreadgroup: groupSize)
		encoder.endEncoding()
		
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
	}
}
