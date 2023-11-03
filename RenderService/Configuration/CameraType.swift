//
//  Lens.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import Foundation

enum CameraType {
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
		let lenses: Array<ThickLensFile.Lens>
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
	
	var lenses: Array<Lens> {
		switch self {
		case .thickLens(let lens):
			return lens.lenses.flatMap { [
				Lens(
					centerpoint: simd_float3(0, 0, -Float($0.position + $0.thickness)),
					radius: Float($0.frontRadius),
					refractive_index: 1/Float($0.refractiveIndex),
					concave: $0.frontIsConcave
				),
				Lens(
					centerpoint: simd_float3(0, 0, -Float($0.position)),
					radius: Float($0.backRadius),
					refractive_index: Float($0.refractiveIndex),
					concave: !$0.backIsConcave
				)
			]}
		default:
			return []
		}
	}
}
