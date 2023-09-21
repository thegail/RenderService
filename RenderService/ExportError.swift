//
//  ExportError.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

enum ExportError: Error, LocalizedError {
	case context, makeImage, destination, finalize
}
