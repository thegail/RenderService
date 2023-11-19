//
//  MeshBuilderApp.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/14/23.
//

import SwiftUI

@main
struct MeshBuilderApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MeshBuilderDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
