//
//  SettingsView.swift
//  ControlRoom
//
//  Created by Dave DeLong on 2/16/20.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Window", systemImage: "macwindow") {
                TogglesFormView()
            }

            Tab("Shortcuts", systemImage: "keyboard") {
                NotificationsFormView()
            }

            Tab("Screenshots", systemImage: "camera.on.rectangle") {
                PickersFormView()
            }

            Tab("Colors", systemImage: "paintpalette") {
                ColorPickerView()
            }

            Tab("Locations", systemImage: "externaldrive") {
                PathToTerminalTextFieldView()
            }
        }
        .frame(minWidth: 550)
    }
}

#Preview {
    SettingsView()
        .environmentObject(Preferences())
}
