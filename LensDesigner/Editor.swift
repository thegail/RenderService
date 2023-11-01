//
//  Editor.swift
//  LensDesigner
//
//  Created by NUS17468-11-thegail on 11/1/23.
//

import SwiftUI

struct Editor: View {
    @Binding var document: LensDesignerDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(document: .constant(LensDesignerDocument()))
    }
}
