//
//  ControlButtonStyle.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/2/23.
//

import SwiftUI

struct ControlButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		ZStack {
			RoundedRectangle(cornerRadius: 5)
				.foregroundColor(.black)
				.opacity(configuration.isPressed ? 0.9 : 0.7)
				.shadow(color: .black, radius: 1)
			configuration.label
				.foregroundColor(.white)
		}
		.frame(width: 30, height: 30)
	}
}
