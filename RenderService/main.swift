//
//  main.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

let configuration = RenderConfiguration(width: 1080, height: 1080, maxBounces: 6)
let renderer = try Renderer(device: RenderDevice(), config: configuration)

let samples = 10_000
for i in 1...samples {
	try renderer.draw()
	if i % 100 == 0 {
		print("\((100 * i) / samples)%")
	}
}

let output = try renderer.export()
try exportPNG(data: output, filePath: URL(filePath: "/Users/thegail/Desktop/render.png"), width: configuration.width, height: configuration.height)
