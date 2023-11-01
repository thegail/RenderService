//
//  Lens.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI

struct Lens: Shape {
	let frontRadius: CGFloat
	let backRadius: CGFloat
	let frontIsConcave: Bool
	let backIsConcave: Bool
	let distance: CGFloat
	
	func path(in rect: CGRect) -> Path {
		let signedFrontRadius = (self.frontIsConcave ? -1 : 1) * self.frontRadius
		let frontCenter: CGFloat
		if self.frontIsConcave {
			let startX = sqrt(self.frontRadius * self.frontRadius - rect.height * rect.height / 4)
			frontCenter = rect.minX - startX
		} else {
			frontCenter = rect.minX + self.frontRadius
		}
		
		let signedBackRadius = (self.backIsConcave ? -1 : 1) * self.backRadius
		let backCenter = frontCenter - signedFrontRadius + self.distance - signedBackRadius
		
		let frontEllipse = CGPath(ellipseIn: CGRect(
			x: frontCenter - frontRadius,
			y: rect.midY - frontRadius,
			width: 2 * frontRadius,
			height: 2 * frontRadius
		), transform: nil)
		let backEllipse = CGPath(ellipseIn: CGRect(
			x: backCenter - backRadius,
			y: rect.midY - backRadius,
			width: 2 * backRadius,
			height: 2 * backRadius
		), transform: nil)
		
		var path = CGPath(rect: rect, transform: nil)
		if self.frontIsConcave {
			path = path.subtracting(frontEllipse)
		} else {
			path = path.intersection(frontEllipse)
		}
		if self.backIsConcave {
			path = path.subtracting(backEllipse)
		} else {
			path = path.intersection(backEllipse)
		}
		
		return Path(path)
	}
}
