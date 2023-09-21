//
//  RenderError.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

enum RenderError: LocalizedError {
	case device, commandQueue, commandBuffer, computePipeline
	case library, targetTexture, commandEncoder, uniformsBuffer
	case inspectionTexture, blitEncoder
}
