//
//  ImageExporter.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func exportPNG(data: Data, filePath: URL, width: Int, height: Int) throws {
	var data = Array<UInt8>(data)
	let context = CGContext(
		data: &data,
		width: width,
		height: height,
		bitsPerComponent: 8,
		bytesPerRow: 4 * width,
		space: CGColorSpaceCreateDeviceRGB(),
		bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
	)
	
	guard let context = context else {
		throw ExportError.context
	}
	context.flush()
	
	guard let image = context.makeImage() else {
		throw ExportError.makeImage
	}
	
	let destination = CGImageDestinationCreateWithURL(filePath as CFURL, UTType.png.identifier as CFString, 1, nil)
	guard let destination = destination else {
		throw ExportError.destination
	}
	
	CGImageDestinationAddImage(destination, image, nil)
	guard CGImageDestinationFinalize(destination) else {
		throw ExportError.finalize
	}
}
