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
	
	func makeInspectionTexture(width: Int, height: Int) throws -> MTLTexture {
		let descriptor = MTLTextureDescriptor()
		descriptor.width = width
		descriptor.height = height
		descriptor.usage = [.shaderWrite]
		descriptor.storageMode = .shared
		descriptor.pixelFormat = .bgra8Unorm
		
		guard let texture = self.inner.makeTexture(descriptor: descriptor) else {
			throw RenderError.inspectionTexture
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
	
	func makeDataBuffer<T>(data: Array<T>) throws -> MTLBuffer {
		let buffer = self.inner.makeBuffer(
			bytes: data,
			length: data.count * MemoryLayout<T>.stride
		)
		guard let buffer = buffer else {
			throw RenderError.dataBuffer
		}
		
		return buffer
	}
	
	func makeAccelerationStructure(vertices: Array<SIMD3<Float>>, triangles: Array<Triangle>) throws -> MTLAccelerationStructure {
		let vertexBuffer = try self.makeDataBuffer(data: vertices)
		let primitiveBuffer = try self.makeDataBuffer(data: triangles)
		
		let geometryDescriptor = MTLAccelerationStructureTriangleGeometryDescriptor()
		geometryDescriptor.vertexBuffer = vertexBuffer
		geometryDescriptor.vertexStride = MemoryLayout<SIMD3<Float>>.stride
		geometryDescriptor.triangleCount = triangles.count
		geometryDescriptor.primitiveDataBuffer = primitiveBuffer
		geometryDescriptor.primitiveDataStride = MemoryLayout<Triangle>.stride
		geometryDescriptor.primitiveDataElementSize = MemoryLayout<Triangle>.stride

		let structureDescriptor = MTLPrimitiveAccelerationStructureDescriptor()
		structureDescriptor.geometryDescriptors = [geometryDescriptor]
		
		let sizes = self.inner.accelerationStructureSizes(descriptor: structureDescriptor)
		guard let structure = self.inner.makeAccelerationStructure(size: sizes.accelerationStructureSize) else {
			throw RenderError.accelerationStructure
		}
		guard let scratchBuffer = self.inner.makeBuffer(length: sizes.buildScratchBufferSize) else {
			throw RenderError.dataBuffer
		}
		
		let commandBuffer = try self.makeCommandBuffer()
		guard let encoder = commandBuffer.makeAccelerationStructureCommandEncoder() else {
			throw RenderError.accelerationStructure
		}
		let compactedSizeBuffer = self.inner.makeBuffer(length: MemoryLayout<UInt32>.stride, options: .storageModeShared)
		guard let compactedSizeBuffer = compactedSizeBuffer else {
			throw RenderError.uniformsBuffer
		}
		
		encoder.build(accelerationStructure: structure, descriptor: structureDescriptor, scratchBuffer: scratchBuffer, scratchBufferOffset: 0)
		encoder.writeCompactedSize(accelerationStructure: structure, buffer: compactedSizeBuffer, offset: 0)
		encoder.endEncoding()
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
		
		let compactedSize = compactedSizeBuffer.contents().assumingMemoryBound(to: UInt32.self).pointee
		guard let compactedStructure = self.inner.makeAccelerationStructure(size: Int(compactedSize)) else {
			throw RenderError.accelerationStructure
		}
		let copyCommandBuffer = try self.makeCommandBuffer()
		guard let copyEncoder = copyCommandBuffer.makeAccelerationStructureCommandEncoder() else {
			throw RenderError.accelerationStructure
		}
		copyEncoder.copyAndCompact(sourceAccelerationStructure: structure, destinationAccelerationStructure: compactedStructure)
		copyEncoder.endEncoding()
		copyCommandBuffer.commit()
		copyCommandBuffer.waitUntilCompleted()
		return compactedStructure
	}
}
