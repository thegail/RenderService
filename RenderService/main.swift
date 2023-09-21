//
//  main.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

let configuration = RenderConfiguration(width: 100, height: 100, maxBounces: 3)
let renderer = try Renderer(device: RenderDevice(), config: configuration)

for _ in 1...2000 {
	try renderer.draw()
}

let output = try renderer.export()
try exportPNG(data: output, filePath: URL(filePath: "/Users/thegail/Desktop/render.png"), width: 100, height: 100)
