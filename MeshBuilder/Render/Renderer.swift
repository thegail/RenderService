//
//  Renderer.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/14/23.
//

import MetalKit

class Renderer {
	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	let renderPipeline: MTLRenderPipelineState
	let depthState: MTLDepthStencilState
	var primitiveCount: Int
	var vertexBuffer: MTLBuffer
	var primitiveBuffer: MTLBuffer
	let uniformsBuffer: MTLBuffer
	let scene: RenderScene
	var width: Int
	var height: Int
	
	init(scene: RenderScene) throws {
		self.device = try Self.getDevice()
		self.commandQueue = try Self.getCommandQueue(device: self.device)
		self.renderPipeline = try Self.makeRenderPipeline(device: self.device)
		self.depthState = try Self.makeDepthState(device: self.device)
		let primitives = scene.primitives
		self.primitiveCount = primitives.count
		self.vertexBuffer = try Self.makeBuffer(device: device, data: scene.vertices)
		self.primitiveBuffer = try Self.makeBuffer(device: device, data: primitives)
		self.uniformsBuffer = try Self.makeBuffer(device: device, data: [Uniforms(camera: SIMD3(0, 0, 0), matrix: simd_float4x4())])
		self.scene = scene
		self.width = 1
		self.height = 1
	}
	
	func draw(in view: MTKView) throws {
		guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
			throw RenderError.commandBuffer
		}
		
		guard let renderPass = view.currentRenderPassDescriptor else {
			throw RenderError.renderPass
		}
		guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
			throw RenderError.commandEncoder
		}
		
		encoder.setRenderPipelineState(self.renderPipeline)
		encoder.setDepthStencilState(self.depthState)
		encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
		encoder.setVertexBuffer(self.uniformsBuffer, offset: 0, index: 1)
		encoder.setFragmentBuffer(self.primitiveBuffer, offset: 0, index: 0)
		encoder.setFragmentBuffer(self.uniformsBuffer, offset: 0, index: 1)
		encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.primitiveCount * 3)
		encoder.endEncoding()
		
		guard let drawable = view.currentDrawable else {
			throw RenderError.drawable
		}
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
	
	func updateSize(width: Int, height: Int) throws {
		self.width = width
		self.height = height
		self.updateUniforms()
	}
	
	private func updateUniforms() {
		let aspectRatio = Float(self.width) / Float(self.height)
		let aspectRatioMatrix = simd_float4x4(diagonal: SIMD4(1 / aspectRatio, 1, 1, 1))
		let uniforms = self.uniformsBuffer.contents().assumingMemoryBound(to: Uniforms.self)
		uniforms.pointee.camera = self.scene.camera.position
		uniforms.pointee.matrix = aspectRatioMatrix * self.scene.camera.transformationMatrix
	}
	
	static func getDevice() throws -> MTLDevice {
		guard let device = MTLCreateSystemDefaultDevice() else {
			throw RenderError.device
		}
		return device
	}
	
	static func getCommandQueue(device: MTLDevice) throws -> MTLCommandQueue {
		guard let queue = device.makeCommandQueue() else {
			throw RenderError.commandQueue
		}
		return queue
	}
	
	static func makeRenderPipeline(device: MTLDevice) throws -> MTLRenderPipelineState {
		guard let library = device.makeDefaultLibrary() else {
			throw RenderError.library
		}
		guard let vertex = library.makeFunction(name: "render_vertex") else {
			throw RenderError.shader
		}
		guard let fragment = library.makeFunction(name: "render_fragment") else {
			throw RenderError.shader
		}
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertex
		descriptor.fragmentFunction = fragment
		descriptor.depthAttachmentPixelFormat = .depth32Float
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		do {
			return try device.makeRenderPipelineState(descriptor: descriptor)
		} catch {
			throw RenderError.pipeline
		}
	}
	
	static func makeDepthState(device: MTLDevice) throws -> MTLDepthStencilState {
		let descriptor = MTLDepthStencilDescriptor()
		descriptor.depthCompareFunction = .lessEqual
		descriptor.isDepthWriteEnabled = true
		guard let depthState = device.makeDepthStencilState(descriptor: descriptor) else {
			throw RenderError.depthState
		}
		
		return depthState
	}
	
	static func makeBuffer<T>(device: MTLDevice, data: Array<T>) throws -> MTLBuffer {
		guard let buffer = device.makeBuffer(bytes: data, length: MemoryLayout<T>.stride * data.count) else {
			throw RenderError.buffer
		}
		return buffer
	}
}
