//
//  Lens.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import Foundation

enum Lens {
	case pinhole
	case thinLens(ThinLens)
	case thickLens(ThickLens)
	
	struct ThinLens {
		let aperture: Float
		let focusDistance: Float
	}
	
	struct ThickLens {
		let aperture: Float
		let lensDistance: Float
		let sampleScreenSize: SIMD2<Float>
		let apertureDistance: Float
		let lensThickness: Float
	}
	
	var cameraTypeID: UInt8 {
		switch self {
		case .pinhole:
			return 0
		case .thinLens(_):
			return 1
		case .thickLens(_):
			return 2
		}
	}
	
	var aperture: Float {
		switch self {
		case .thinLens(let lens):
			return lens.aperture
		case .thickLens(let lens):
			return lens.aperture
		default:
			return 0
		}
	}
	
	var lensDistance: Float {
		switch self {
		case .thickLens(let lens):
			return lens.lensDistance
		default:
			return 0
		}
	}
	
	var focusDistance: Float {
		switch self {
		case .thinLens(let lens):
			return lens.focusDistance
		default:
			return 0
		}
	}
	
	var sampleScreenSize: SIMD2<Float> {
		switch self {
		case .thickLens(let lens):
			return lens.sampleScreenSize
		default:
			return SIMD2(repeating: 0)
		}
	}
	
	var apertureDistance: Float {
		switch self {
		case .thickLens(let lens):
			return lens.apertureDistance
		default:
			return 0
		}
	}
	
	var thickness: Float {
		switch self {
		case .thickLens(let lens):
			return lens.lensThickness
		default:
			return 0
		}
	}
}
