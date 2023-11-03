//
//  Editor.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI

enum SelectedItem: Hashable {
	case screen
	case aperture
	case lens(index: Int)
}

struct Editor: View {
    @Binding var document: LensDesignerDocument
	@State var selectedItem: SelectedItem?
	@State var scaleFactor: Double = 50
	let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		formatter.minimum = 0
		return formatter
	}()
	var lens: Binding<LensModel> {
		if case .lens(index: let index) = self.selectedItem {
			return self.$document.lenses[index]
		} else {
			return .constant(LensModel(position: 0, frontRadius: 0, backRadius: 0, frontIsConcave: false, backIsConcave: false, thickness: 0, refractiveIndex: 0))
		}
	}
	
	func format(_ number: Double) -> String {
		return self.numberFormatter.string(from: number as NSNumber) ?? ""
	}

    var body: some View {
		HStack(spacing: 0) {
			ZStack {
				GeometryReader { geometry in
					ForEach(Array(self.document.lenses.enumerated()), id: \.offset) { (index, lens) in
						Lens(
							frontRadius: lens.frontRadius * self.scaleFactor,
							backRadius: lens.backRadius * self.scaleFactor,
							frontIsConcave: lens.frontIsConcave,
							backIsConcave: lens.backIsConcave,
							distance: lens.thickness * self.scaleFactor
						)
							.fill(.blue.opacity(self.selectedItem == .lens(index: index) ? 0.6 : 0.3))
							.frame(width: 50, height: 100)
							.position(
								x: geometry.size.width - 25 - lens.position * 50,
								y: geometry.size.height / 2
							)
							.onTapGesture {
								self.selectedItem = .lens(index: index)
							}
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				HStack {
					Button(action: {
						var lens = LensModel.default
						lens.position = (self.document.lenses.map { $0.position }.max() ?? 0) + 1
						self.document.lenses.append(lens)
					}, label: {
						Image(systemName: "plus")
					})
					Button(action: {
						guard case .lens(index: let index) = self.selectedItem else {
							return
						}
						self.selectedItem = nil
						self.document.lenses.remove(at: index)
					}, label: {
						Image(systemName: "trash.slash")
					})
				}
				.buttonStyle(ControlButtonStyle())
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
			}
			.padding()
			.focusSection()
			.frame(minWidth: 400, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
			
			VStack(alignment: .trailing) {
				VStack {
					Text("Position")
						.bold().bold()
					HStack {
						Slider(value: self.lens.position, in: 0...10)
						TextField("", value: self.lens.position, formatter: self.numberFormatter)
							.frame(width: 40)
					}
				}
				Divider()
				VStack {
					Text("Front Radius")
						.bold().bold()
					HStack {
						Slider(value: self.lens.frontRadius, in: 0...10)
						TextField("", value: self.lens.frontRadius, formatter: self.numberFormatter)
							.frame(width: 40)
					}
					Picker(selection: self.lens.frontIsConcave, content: {
						Text("Convex").tag(false)
						Text("Concave").tag(true)
					}, label: {})
				}
				Divider()
				VStack {
					Text("Back Radius")
						.bold().bold()
					HStack {
						Slider(value: self.lens.backRadius, in: 0...10)
						TextField("", value: self.lens.backRadius, formatter: self.numberFormatter)
							.frame(width: 40)
					}
					Picker(selection: self.lens.backIsConcave, content: {
						Text("Convex").tag(false)
						Text("Concave").tag(true)
					}, label: {})
				}
				Divider()
				VStack(alignment: .trailing) {
					Text("Thickness")
						.frame(maxWidth: .infinity)
						.bold().bold()
					HStack {
						Slider(value: self.lens.thickness, in: 0...1)
						TextField("", value: self.lens.thickness, formatter: self.numberFormatter)
							.frame(width: 40)
					}
					HStack {
						Text("Refractive Index")
						TextField("", value: self.lens.refractiveIndex, format: .number)
							.frame(width: 40)
					}
				}
			}
			.disabled(self.selectedItem == nil)
			.frame(minWidth: 150, maxWidth: 200, maxHeight: .infinity, alignment: .top)
			.padding()
			.background(.gray.opacity(0.2))
			.focusSection()
		}
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(document: .constant(LensDesignerDocument()))
    }
}
