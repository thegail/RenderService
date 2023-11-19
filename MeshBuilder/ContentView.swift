//
//  ContentView.swift
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/14/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: MeshBuilderDocument

    var body: some View {
		RenderView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(MeshBuilderDocument()))
    }
}
