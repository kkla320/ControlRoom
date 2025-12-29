//
//  LocationView.swift
//  ControlRoom
//
//  Created by Stefano Mondino on 13/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import MapKit
import SwiftUI
import CoreLocation

/// Map view to change simulated user's position
struct LocationView: View {
    @ObservedObject var controller: SimulatorsController
    let simulator: Simulator
    static let DEFAULT_LAT = 37.323056
    static let DEFAULT_LNG = -122.031944

    /// Saved locations controller.
    @StateObject private var locationsController = LocationsController()
    /// Current table selection binding.
    @State private var previouslyPickedLocation: Location.ID?

    /// Indicates whether save location alert is currently presented.
    @State private var isShowingNewLocationAlert = false

    /// The location that is being simulated
    @State private var currentLocation = Location(id: UUID(), name: "", latitude: DEFAULT_LAT, longitude: DEFAULT_LNG)
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: DEFAULT_LAT, longitude: DEFAULT_LNG),
            span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
        )
    )
    @State private var selectedLocation: Location.ID?
    
    @State private var showInspector: Bool = true
    
    /// User-facing text describing `currentLocation`
    var locationText: String {
        let location = currentLocation.center
        return String(format: "%.5f, %.5f", location.latitude, location.longitude)
    }

    var body: some View {
        Map(position: $mapPosition) {
            ForEach(locationsController.locations) { location in
                Marker(coordinate: location.center) {
                    Text(location.name)
                }
                .tag(location.id)
            }
        }
        .overlay {
            Image(systemName: "dot.scope")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.tint)
                .shadow(radius: 5)
                .allowsHitTesting(false)
        }
        .safeAreaBar(edge: .bottom) {
            GlassEffectContainer {
                HStack(spacing: 8) {
                    Button {
                        copyCoordinatesToClipboard()
                    } label: {
                        Label {
                            Text(locationText)
                                .fontDesign(.monospaced)
                        } icon: {
                            Image(systemName: "document.on.document.fill")
                        }
                        .padding(6)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)

                    Button {
                        isShowingNewLocationAlert = true
                    } label: {
                        Text("Save")
                            .padding(6)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    
                    Button {
                        changeLocation()
                    } label: {
                        Text("Activate")
                            .padding(6)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                }
            }
            .padding(.bottom)
        }
        .onMapCameraChange(frequency: .continuous) { (context: MapCameraUpdateContext) in
            currentLocation = Location(
                id: currentLocation.id,
                name: currentLocation.name,
                latitude: context.region.center.latitude,
                longitude: context.region.center.longitude
            )
        }
        .inspector(isPresented: $showInspector) {
            List(selection: $previouslyPickedLocation) {
                ForEach(locationsController.locations) { location in
                    Text("\(location.name)")
                        .contextMenu {
                            Button("Delete") {
                                locationsController.delete(location.id)
                            }
                        }
                        .tag(location.id)
                }
            }
            .listStyle(.sidebar)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Toggle(
                    "Inspector",
                    systemImage: "sidebar.trailing",
                    isOn: $showInspector
                )
            }
        }
        .onChange(of: previouslyPickedLocation, updatePickedLocation)
        .animation(.default, value: mapPosition)
        .newLocationAlert(isPresented: $isShowingNewLocationAlert) { name in
            savePickedLocation(name: name)
        }
    }

    /// Updates the simulated location to the value of `currentLocation`.
    func changeLocation() {
        let coordinate = currentLocation.center

        SimCtl.execute(.location(deviceId: simulator.udid, latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    /// Copies `currentLocation` to the clipboard
    private func copyCoordinatesToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(currentLocation.toString(), forType: .string)
    }

    /// Saves currently selected location to user's collection.
    private func savePickedLocation(name: String) {
        let latitude = currentLocation.center.latitude
        let longitude = currentLocation.center.longitude
        locationsController.create(name: name, latitude: latitude, longitude: longitude)
    }

    /// Updates current location on the map when saved location is selected from the table.
    private func updatePickedLocation() {
        guard let location = locationsController.item(with: previouslyPickedLocation) else {
            return
        }
        selectedLocation = location.id
        mapPosition = .region(
            MKCoordinateRegion(
                center: location.center,
                span: MKCoordinateSpan(latitudeDelta: location.latitudeDelta, longitudeDelta: location.longitudeDelta)
            )
        )
    }
}
