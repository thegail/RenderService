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
	var depthTexture: MTLTexture
	var primitiveCount: Int
	var vertexBuffer: MTLBuffer
	var primitiveBuffer: MTLBuffer
	let uniformsBuffer: MTLBuffer
	let scene: RenderScene
	
	init(scene: RenderScene) throws {
		self.device = try Self.getDevice()
		self.commandQueue = try Self.getCommandQueue(device: self.device)
		self.renderPipeline = try Self.makeRenderPipeline(device: self.device)
		self.depthTexture = try Self.makeDepthTexture(device: self.device, width: 1, height: 1)
		let primitives = scene.primitives
		self.primitiveCount = primitives.count
		self.vertexBuffer = try Self.makeBuffer(device: device, data: scene.vertices)
		self.primitiveBuffer = try Self.makeBuffer(device: device, data: primitives)
		self.uniformsBuffer = try Self.makeBuffer(device: device, data: [Uniforms(camera: scene.camera.position, matrix: scene.camera.transformationMatrix)])
		self.scene = scene
	}
	
	func draw(in view: MTKView) throws {
		guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
			throw RenderError.commandBuffer
		}
		
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.depthAttachment.texture = self.depthTexture
		guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
			throw RenderError.commandEncoder
		}
		
		encoder.setRenderPipelineState(self.renderPipeline)
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
		self.depthTexture = try Self.makeDepthTexture(device: self.device, width: width, height: height)
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
		do {
			return try device.makeRenderPipelineState(descriptor: descriptor)
		} catch {
			throw RenderError.pipeline
		}
	}
	
	static func makeDepthTexture(device: MTLDevice, width: Int, height: Int) throws -> MTLTexture {
		let descriptor = MTLTextureDescriptor()
		descriptor.width = width
		descriptor.height = height
		descriptor.pixelFormat = .depth32Float
		descriptor.usage = .renderTarget
		descriptor.storageMode = .private
		
		guard let texture = device.makeTexture(descriptor: descriptor) else {
			throw RenderError.depthTexture
		}
		return texture
	}
	
	static func makeBuffer<T>(device: MTLDevice, data: Array<T>) throws -> MTLBuffer {
		guard let buffer = device.makeBuffer(bytes: data, length: MemoryLayout<T>.stride * data.count) else {
			throw RenderError.buffer
		}
		return buffer
	}
}
