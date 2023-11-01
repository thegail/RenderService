//
//  LensDesignerApp.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI

@main
struct LensDesignerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: LensDesignerDocument()) { file in
			Editor(document: file.$document)
        }
    }
}
