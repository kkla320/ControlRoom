//
//  PathToTerminalTextFieldView.swift
//  ControlRoom
//
//  Created by Elliot Knight on 11/05/2024.
//  Copyright © 2024 Paul Hudson. All rights reserved.
//

import SwiftUI

struct PathToTerminalTextFieldView: View {
    @EnvironmentObject var preferences: Preferences
    
    @State private var showFileImporter = false
    
    var body: some View {
        Form {
            LabeledContent {
                HStack {
                    TextField(
                        "Path to Terminal",
                        text: $preferences.terminalAppPath
                    )
                    Button("Open", systemImage: "arrow.up.right.square") {
                        showFileImporter = true
                    }
                    .labelStyle(.iconOnly)
                }
                .labelsHidden()
            } label: {
                Text("Path to Terminal")
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.application]) { result in
                switch result {
                case .success(let success):
                    preferences.terminalAppPath = success.absoluteString
                case .failure:
                    preferences.setDefaultTerminalAppPath()
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    PathToTerminalTextFieldView()
        .environmentObject(Preferences())
}
