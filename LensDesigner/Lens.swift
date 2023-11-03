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
		let signedBackRadius = (self.backIsConcave ? -1 : 1) * self.backRadius
		let backCenter: CGFloat
		if self.backIsConcave {
			let endX = sqrt(self.backRadius * self.backRadius - rect.height * rect.height / 4)
			backCenter = rect.maxX + endX
		} else {
			backCenter = rect.maxX - self.backRadius
		}
		
		let signedFrontRadius = (self.frontIsConcave ? -1 : 1) * self.frontRadius
		let frontCenter = backCenter + signedBackRadius - self.distance + signedFrontRadius
		
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
