//
//  main.swift
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

import Foundation

let configuration = RenderConfiguration(width: 100, height: 100)
let renderer = try Renderer(device: RenderDevice(), config: configuration)
try renderer.draw()
