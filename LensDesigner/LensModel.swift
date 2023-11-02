//
//  LensModel.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/2/23.
//

import Foundation

struct LensModel: Codable {
	var position: Double
	var frontRadius: Double
	var backRadius: Double
	var frontIsConcave: Bool
	var backIsConcave: Bool
	var thickness: Double
	var refractiveIndex: Double
	
	static let `default` = LensModel(
		position: 0,
		frontRadius: 3,
		backRadius: 3,
		frontIsConcave: false,
		backIsConcave: false,
		thickness: 0.25,
		refractiveIndex: 1.5
	)
}
