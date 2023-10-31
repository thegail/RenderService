//
//  main.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

let configuration = RenderConfiguration(width: 300, height: 300, maxBounces: 4)
let renderer = try Renderer(device: RenderDevice(), config: configuration)

let samples = 10000
for _ in 1...samples {
	try renderer.draw()
}

let output = try renderer.export()
try exportPNG(data: output, filePath: URL(filePath: "/Users/thegail/Desktop/render_\(Int(Date().timeIntervalSince1970)).png"), width: configuration.width, height: configuration.height)
