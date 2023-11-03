//
//  ThickLensFile.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/2/23.
//

import Foundation

struct LensFile: Codable {
	var lenses: Array<Lens>
	var apertureDistance: Double
	var aperture: Double
	var screenWidth: Double
	var screenHeight: Double
	var screenDistance: Double
	
	init(file: URL) throws {
		let data = try Data(contentsOf: file)
		let decoder = PropertyListDecoder()
		self = try decoder.decode(Self.self, from: data)
	}
	
	struct Lens: Codable {
		var position: Double
		var frontRadius: Double
		var backRadius: Double
		var frontIsConcave: Bool
		var backIsConcave: Bool
		var thickness: Double
		var refractiveIndex: Double
	}
}
