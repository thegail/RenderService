//
//  UTType+lens.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/2/23.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
	static var lens: UTType {
		UTType(exportedAs: "co.thegail.lens")
	}
}
