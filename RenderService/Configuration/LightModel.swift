//
//  LightModel.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/7/23.
//

import Metal

enum LightModel {
	case beckmann
	case phong
	case ggx
	case principled
	
	func setFunctionConstants(_ constants: MTLFunctionConstantValues) {
		var bsdfType: UInt8
		switch self {
		case .beckmann:
			bsdfType = 0
		case .phong:
			bsdfType = 1
		case .ggx:
			bsdfType = 2
		case .principled:
			bsdfType = 3
		}
		constants.setConstantValue(&bsdfType, type: .uchar, withName: "bsdf_type")
	}
}
