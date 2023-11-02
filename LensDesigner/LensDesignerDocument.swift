//
//  LensDesignerDocument.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct LensDesignerDocument: FileDocument {
    var lenses: Array<LensModel>

    init() {
		self.lenses = [.default]
    }

	static var readableContentTypes: [UTType] { [.lens] }

    init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
		let decoder = PropertyListDecoder()
		do {
			self.lenses = try decoder.decode(Array<LensModel>.self, from: data)
		} catch {
			throw CocoaError(.fileReadCorruptFile)
		}
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = PropertyListEncoder()
		encoder.outputFormat = .binary
		let data = try encoder.encode(self.lenses)
        return .init(regularFileWithContents: data)
    }
}
