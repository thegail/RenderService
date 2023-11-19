//
//  RenderView.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/14/23.
//

import SwiftUI
import MetalKit

struct RenderView: NSViewRepresentable {
	func makeNSView(context: Context) -> some NSView {
		let mtkView = MTKView()
		mtkView.delegate = context.coordinator
		return mtkView
	}
	
	func makeCoordinator() -> RenderDelegate {
		return RenderDelegate()
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context) { }
	
	class RenderDelegate: NSObject, MTKViewDelegate {
		let renderer: Renderer
		
		override init() {
			do {
				self.renderer = try Renderer(scene: makeDefaultScene())
			} catch let error {
				print(error)
				exit(1)
			}
		}
		
		func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
			do {
				try self.renderer.updateSize(width: Int(size.width), height: Int(size.height))
			} catch let error {
				print(error)
			}
		}
		
		func draw(in view: MTKView) {
			do {
				try self.renderer.draw(in: view)
			} catch let error {
				print(error)
			}
		}
	}
}
