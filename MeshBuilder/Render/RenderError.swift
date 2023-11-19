//
//  RenderError.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/17/23.
//

import Foundation

enum RenderError: Error {
	case device, library, shader, pipeline, buffer
	case commandQueue, commandBuffer, depthTexture
	case commandEncoder, drawable
}
