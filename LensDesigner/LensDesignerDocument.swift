//
//  LensDesignerDocument.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct LensDesignerDocument: Codable, FileDocument {
    var lenses: Array<LensModel>
	var apertureDistance: Double
	var aperture: Double
	var screenWidth: Double
	var screenHeight: Double
	var screenDistance: Double

    init() {
		self.lenses = [.default]
		self.apertureDistance = 0.05
		self.aperture = 3
		self.screenWidth = 1
		self.screenHeight = 1
		self.screenDistance = 1
    }

	static var readableContentTypes: [UTType] { [.lens] }

    init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
		let decoder = PropertyListDecoder()
		do {
			self = try decoder.decode(Self.self, from: data)
		} catch {
			throw CocoaError(.fileReadCorruptFile)
		}
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = PropertyListEncoder()
		encoder.outputFormat = .binary
		let data = try encoder.encode(self)
        return .init(regularFileWithContents: data)
    }
}
