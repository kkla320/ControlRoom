//
//  ControlView.swift
//  ControlRoom
//
//  Created by Paul Hudson on 12/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import SwiftUI

/// The main tab view to control simulator settings.
struct ControlView: View {
    /// Used to handle creating screenshots, videos, and GIFs.
    @StateObject private var captureController = CaptureController()

    /// Let's us watch the list of active simulators.
    @ObservedObject var controller: SimulatorsController

    let simulator: Simulator
    let applications: [Application]

    var body: some View {
        TabView {
            Tab {
                SystemView(simulator: simulator)
            } label: {
                Text("System")
            }
            .disabled(simulator.state != .booted)
            
            Tab {
                SnapshotsView(simulator: simulator, controller: controller)
            } label: {
                Text("Snapshots")
            }
            
            Tab {
                AppView(simulator: simulator, applications: applications)
            } label: {
                Text("App")
            }
            .disabled(simulator.state != .booted)

            Tab {
                LocationView(controller: controller, simulator: simulator)
            } label: {
                Text("Location")
            }
            .disabled(simulator.state != .booted)

            Tab {
                StatusBarView(simulator: simulator)
            } label: {
                Text("Statusbar")
            }
            .disabled(simulator.state != .booted)
            
            Tab {
                OverridesView(simulator: simulator)
            } label: {
                Text("Overrides")
            }
            .disabled(simulator.state != .booted)
            
            Tab {
                ColorsView()
            } label: {
                Text("Colors")
            }
            .disabled(simulator.state != .booted)

        }
        .navigationSubtitle("\(simulator.name) – \(simulator.runtime?.name ?? "Unknown OS")")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu("Save \(captureController.imageFormatString)", systemImage: "camera") {
                    Button("Save as PNG") {
                        captureController.takeScreenshot(of: simulator, format: .png)
                    }
                    
                    Button("Save as JPEG") {
                        captureController.takeScreenshot(of: simulator, format: .jpeg)
                    }
                    
                    Button("Save as TIFF") {
                        captureController.takeScreenshot(of: simulator, format: .tiff)
                    }
                    
                    Button("Save as BMP") {
                        captureController.takeScreenshot(of: simulator, format: .bmp)
                    }
                } primaryAction: {
                    captureController.takeScreenshot(of: simulator)
                }

                if captureController.recordingProcess == nil {
                    Menu("Record \(captureController.videoFormatString)", systemImage: "record.circle") {
                        ForEach(SimCtl.IO.VideoFormat.all, id: \.self) { item in
                            if item == .divider {
                                Divider()
                            } else {
                                Button("Save as \(item.name)") {
                                    captureController.startRecordingVideo(of: simulator, format: item)
                                }
                            }
                        }
                    } primaryAction: {
                        captureController.startRecordingVideo(of: simulator)
                    }
                } else {
                    Button(
                        "Stop Recording",
                        systemImage: "record.circle.fill",
                        action: captureController.stopRecordingVideo
                    )
                }
                
                if simulator.state != .booted {
                    Button("Boot", systemImage: "poweron", action: bootDevice)
                }
                
                if simulator.state != .shutdown {
                    Button("Shutdown", systemImage: "poweroff", action: shutdownDevice)
                }
            }
        }
    }

    /// Launches the current device.
    func bootDevice() {
        SimCtl.boot(simulator)
    }

    /// Terminates the current device.
    func shutdownDevice() {
        SimCtl.shutdown(simulator.udid)
    }
}

#Preview {
    ControlView(
        controller: .init(preferences: .init()),
        simulator: .example,
        applications: []
    )
    .environmentObject(Preferences())
}
