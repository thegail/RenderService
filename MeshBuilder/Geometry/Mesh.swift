//
//  Mesh.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/18/23.
//

import Foundation

protocol Mesh {
	var vertices: Array<SIMD3<Float>> { get }
	var primitives: Array<UInt8> { get }
}
