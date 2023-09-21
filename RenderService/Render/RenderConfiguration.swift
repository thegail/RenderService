//
//  RenderConfiguration.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import Metal

struct RenderConfiguration {
	let width: Int
	let height: Int
	let maxBounces: Int
	
	func makeShaderConstants() -> MTLFunctionConstantValues {
		let values = MTLFunctionConstantValues()
		var value: UInt32 = UInt32(self.maxBounces)
		values.setConstantValue(&value, type: .uint, withName: "max_bounces")
		
		return values
	}
}
