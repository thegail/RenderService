//
//  Cube.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/18/23.
//

import Foundation
import simd

class Cube: Mesh {
	let position: SIMD3<Float>
	let rotation: Float
	let scale: SIMD3<Float>
	let faces: Set<Face>
	let inverted: Bool
	let textureID: UInt64?
	
	init(position: SIMD3<Float> = SIMD3<Float>(repeating: 0), rotation: Float = 0, scale: SIMD3<Float> = SIMD3<Float>(repeating: 1), faces: Set<Face> = [.up, .down, .left, .right, .front, .back], inverted: Bool = false, textureID: UInt64? = nil) {
		self.position = position
		self.rotation = rotation
		self.scale = scale
		self.faces = faces
		self.inverted = inverted
		self.textureID = textureID
	}
	
	var rotationMatrix: simd_float3x3 {
		simd_float3x3(columns: (SIMD3(cos(self.rotation), 0, -sin(self.rotation)), SIMD3(0, 1, 0), SIMD3(sin(self.rotation), 0, cos(self.rotation))))
	}
	
	var primitives: Array<Triangle> {
		self.faces.flatMap(self.faceTriangles)
	}
	
	var vertices: Array<SIMD3<Float>> {
		self.rawVertices.map { self.rotationMatrix * $0 * self.scale + self.position }
	}
	
	private var rawVertices: Array<SIMD3<Float>> {
		self.faces.map(Self.faceVertices).reduce([], +)
	}
	
	private func faceTriangles(face: Face) -> Array<Triangle> {
		var normal: SIMD3<Float>
		switch face {
		case .up:
			normal = SIMD3(0, 1, 0)
		case .down:
			normal = SIMD3(0, -1, 0)
		case .left:
			normal = SIMD3(-1, 0, 0)
		case .right:
			normal = SIMD3(1, 0, 0)
		case .front:
			normal = SIMD3(0, 0, -1)
		case .back:
			normal = SIMD3(0, 0, 1)
		}

		normal = normal * self.rotationMatrix
		if self.inverted {
			normal *= -1
		}

		let color = self.scale.y == 1 ? SIMD3<Float>(repeating: 1) : SIMD3<Float>(repeating: 0.5)
		return [Triangle(normal: normal, color: color), Triangle(normal: normal, color: color)]
	}
	
	private static func faceVertices(face: Face) -> Array<SIMD3<Float>> {
		let quad: Array<SIMD3<Float>>
		switch face {
		case .up:
			quad = [
				SIMD3<Float>(0, 1, 1),
				SIMD3<Float>(1, 1, 1),
				SIMD3<Float>(1, 1, 0),
				SIMD3<Float>(0, 1, 0),
			]
		case .down:
			quad = [
				SIMD3<Float>(0, 0, 0),
				SIMD3<Float>(0, 0, 1),
				SIMD3<Float>(1, 0, 1),
				SIMD3<Float>(1, 0, 0),
			]
		case .left:
			quad = [
				SIMD3<Float>(0, 1, 1),
				SIMD3<Float>(0, 1, 0),
				SIMD3<Float>(0, 0, 0),
				SIMD3<Float>(0, 0, 1),
			]
		case .right:
			quad = [
				SIMD3<Float>(1, 1, 0),
				SIMD3<Float>(1, 1, 1),
				SIMD3<Float>(1, 0, 1),
				SIMD3<Float>(1, 0, 0),
			]
		case .front:
			quad = [
				SIMD3<Float>(0, 1, 0),
				SIMD3<Float>(1, 1, 0),
				SIMD3<Float>(1, 0, 0),
				SIMD3<Float>(0, 0, 0),
			]
		case .back:
			quad = [
				SIMD3<Float>(1, 1, 1),
				SIMD3<Float>(0, 1, 1),
				SIMD3<Float>(0, 0, 1),
				SIMD3<Float>(1, 0, 1),
			]
		}
		
		return [quad[0], quad[1], quad[3], quad[2], quad[3], quad[1]]
	}
	
	enum Face {
		case up, down, left, right, front, back
	}
}
