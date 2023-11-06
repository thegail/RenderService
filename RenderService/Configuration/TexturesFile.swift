//
//  TexturesFile.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/6/23.
//

import Foundation

typealias TexturesFile = Array<TextureDescriptor>

extension TexturesFile {
	init(url: URL) throws {
		let data = try Data(contentsOf: url)
		let decoder = PropertyListDecoder()
		self = try decoder.decode(Self.self, from: data)
	}
}
