//
//  Lens.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import Metal

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
		let lenses: Array<LensFile.Lens>
	}
	
	var lensData: Array<Lens> {
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
	
	func setFunctionConstants(_ constants: MTLFunctionConstantValues) {
		switch self {
		case .pinhole:
			var cameraType: UInt8 = 0
			constants.setConstantValue(&cameraType, type: .uchar, withName: "camera_type")
		case .thinLens(let lens):
			var cameraType: UInt8 = 1
			var aperture = lens.aperture
			var focusDistance = lens.focusDistance
			constants.setConstantValue(&cameraType, type: .uchar, withName: "camera_type")
			constants.setConstantValue(&aperture, type: .float, withName: "camera_aperture")
			constants.setConstantValue(&focusDistance, type: .float, withName: "focus_distance")
		case .thickLens(let lens):
			var cameraType: UInt8 = 2
			var aperture = lens.aperture
			var apertureDistance = lens.apertureDistance
			var sampleScreenSize = lens.sampleScreenSize
			var lensDistance = lens.lensDistance
			var lensCount = lens.lenses.count
			constants.setConstantValue(&cameraType, type: .uchar, withName: "camera_type")
			constants.setConstantValue(&aperture, type: .float, withName: "camera_aperture")
			constants.setConstantValue(&apertureDistance, type: .float, withName: "aperture_distance")
			constants.setConstantValue(&sampleScreenSize, type: .float2, withName: "sample_screen_size")
			constants.setConstantValue(&lensDistance, type: .float, withName: "lens_distance")
			constants.setConstantValue(&lensCount, type: .uint, withName: "lens_count")
		}
	}
}
