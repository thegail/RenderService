//
//  main.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

let configuration = try RenderConfiguration(width: 1000, height: 1000, maxBounces: 4, camera: Camera(position: SIMD3(2, 2, 0), pitch: 0, roll: 0, yaw: 0), cameraType: .pinhole, textures: TexturesFile(url: URL(filePath: "/Users/thegail/Desktop/textures.plist")), lightModel: .ggx)
let renderer = try Renderer(device: RenderDevice(), config: configuration)

let samples = 10000
for i in 1...samples {
	try renderer.draw()
	if i % (samples / 100) == 0 {
		print("\(i / (samples / 100))%")
	}
}

let output = try renderer.export()
try exportPNG(data: output, filePath: URL(filePath: "/Users/thegail/Desktop/render_\(Int(Date().timeIntervalSince1970)).png"), width: configuration.width, height: configuration.height)
