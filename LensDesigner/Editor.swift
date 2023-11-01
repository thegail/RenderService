//
//  Editor.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI

struct Editor: View {
    @Binding var document: LensDesignerDocument
	@State var frontRadius: Double = 3
	@State var backRadius: Double = 3
	@State var distance: Double = 0.1

    var body: some View {
		HStack {
			ZStack {
				Lens(frontRadius: self.frontRadius * 50, backRadius: self.backRadius * 50, frontIsConcave: true, backIsConcave: true, distance: self.distance * 50)
					.fill(.blue.opacity(0.3))
					.frame(width: 50, height: 100)
			}
			VStack {
				TextField("Front Radius", value: $frontRadius, format: .number)
				TextField("Back Radius", value: $backRadius, format: .number)
				TextField("Distance", value: $distance, format: .number)
			}
			.frame(width: 100)
		}
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(document: .constant(LensDesignerDocument()))
    }
}
