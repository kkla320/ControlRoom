//
//  StatusBarView.swift
//  ControlRoom
//
//  Created by Paul Hudson on 12/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import SwiftUI

/// Controls WiFi and cellular data state for the whole device.
struct StatusBarView: View {
    let simulator: Simulator

    @Environment(\.calendar) private var calendar
    
    /// The current time to show in the device.
    @State private var time = Date.now

    /// The active data network; can be one of "WiFi", "3G", "4G", "5G", "5G+", "5G-UWB", "LTE", "LTE-A", or "LTE+".
    @State private var dataNetwork: SimCtl.StatusBar.DataNetwork = .wifi

    /// Whether WiFi is currently active; can be "Active", "Searching", or "Failed".
    @State private var wiFiMode: SimCtl.StatusBar.WifiMode = .active

    /// How many WiFi bars the device is showing, as a range from 0 through 3.
    @State private var wiFiBar: SimCtl.StatusBar.WifiBars = .three

    /// Whether cellular data is currently active; can be "Active", "Searching", "Failed", or "Not Supported".
    @State private var cellularMode: SimCtl.StatusBar.CellularMode = .active

    /// How many cellular bars the device is showing, as a range from 0 through 4.
    @State private var cellularBar: SimCtl.StatusBar.CellularBars = .four

    @AppStorage("CRNetwork_CarrierName") private var carrierName = "Carrier"

    /// The current battery level of the device, as a value from 0 through 100
    @State private var batteryLevel = 1.0

    /// The current battery state of the device; must be "Charging", "Charged", or "Discharging"
    /// Note: "Charged" looks the same as "Discharging", so it's not included in this screen.
    @State private var batteryState: SimCtl.StatusBar.BatteryState = .charged

    var body: some View {
        ScrollView {
            Form {
                Section {
                    HStack {
                        Button("Set to 9:41", action: setAppleTime)
                        Spacer()
                        DatePicker("Time", selection: $time)
                            .labelsHidden()
                    }
                    .onChange(of: time, setTime)

                    Button("Clear overrides", action: clearOverrides)
                } header: {
                    Text("Time")
                }

                Section {
                    TextField("Operator", text: $carrierName)
                        .onSubmit {
                            updateCellularData()
                        }
                    
                    Picker("Network type", selection: $dataNetwork) {
                        ForEach(SimCtl.StatusBar.DataNetwork.allCases, id: \.self) { network in
                            Text(network.displayName)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: dataNetwork, updateWiFiData)
                } header: {
                    Text("Network")
                }
                
                Section {
                    Picker("Mode", selection: $wiFiMode) {
                        ForEach(SimCtl.StatusBar.WifiMode.allCases, id: \.self) { mode in
                            Text(mode.displayName)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: wiFiMode, updateWiFiData)
                    
                    Picker("Bars", selection: $wiFiBar) {
                        ForEach(SimCtl.StatusBar.WifiBars.allCases, id: \.self) { bars in
                            Image(systemName: "wifi", variableValue: bars.symbolVariable)
                                .tag(bars.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: wiFiBar, updateWiFiData)
                } header: {
                    Text("Wi-Fi")
                }
                
                Section {
                    Picker("Mode", selection: $cellularMode) {
                        ForEach(SimCtl.StatusBar.CellularMode.allCases, id: \.self) { mode in
                            Text(mode.displayName)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: cellularMode, updateCellularData)

                    Picker("Bars", selection: $cellularBar) {
                        ForEach(SimCtl.StatusBar.CellularBars.allCases, id: \.self) { bars in
                            Image(systemName: "cellularbars", variableValue: bars.symbolVariable)
                                .tag(bars.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: cellularBar, updateCellularData)
                } header: {
                    Text("Cellular")
                }
                
                Section {
                    Picker("State", selection: $batteryState) {
                        ForEach(SimCtl.StatusBar.BatteryState.allCases, id: \.self) { state in
                            Text(state.displayName)
                        }
                    }
                    .onChange(of: batteryState, updateBattery)

                    LabeledContent {
                        HStack {
                            TextField("Level", value: $batteryLevel, format: .percent)
                            Stepper("Level", value: $batteryLevel, in: 0...1, step: 0.01)
                        }
                        .labelsHidden()
                    } label: {
                        Text("Level")
                    }
                    .onChange(of: batteryLevel, updateBattery)
                } header: {
                    Text("Battery")
                }
            }
            .formStyle(.grouped)
        }
    }

    // MARK: Private methods

    /// Changes the system clock to a new value.
    private func setTime() {
        SimCtl.overrideStatusBarTime(simulator.udid, time: time)
    }

	private func setAppleTime() {
        var components = calendar.dateComponents([.year, .month, .day], from: Date.now)
        components.hour = 9
        components.minute = 41
        components.second = 0

        let appleTime = calendar.date(from: components) ?? Date.now

        time = appleTime
    }

    private func clearOverrides() {
        SimCtl.clearStatusBarOverrides(simulator.udid)
        dataNetwork = .wifi
        wiFiBar = .three
        cellularMode = .active
        cellularBar = .four
        batteryLevel = 1
        batteryState = .charged
        carrierName = "Carrier"
    }

    /// Sends status bar updates all at once; simctl gets unhappy if we send them individually, but
    /// also for whatever reason prefers cellular data sent separately from WiFi.
	private func updateWiFiData() {
		SimCtl.overrideStatusBarWiFi(
			simulator.udid,
			network: dataNetwork,
			wifiMode: wiFiMode,
			wifiBars: wiFiBar
		)
    }

    private func updateCellularData() {
		SimCtl.overrideStatusBarCellular(
			simulator.udid,
			cellMode: cellularMode,
			cellBars: cellularBar,
			carrier: carrierName
		)
    }

    /// Sends battery updates all at once; simctl gets unhappy if we send them individually.
    private func updateBattery() {
		SimCtl.overrideStatusBarBattery(
			simulator.udid,
			level: Int(batteryLevel * 100),
			state: batteryState
		)
    }
}

// MARK: Preview

#Preview {
    StatusBarView(simulator: .example)
        .environmentObject(Preferences())
}

// MARK: Extensions

extension SimCtl.StatusBar.DataNetwork {
    var displayName: String {
        switch self {
        case .wifi:
            return "Wi-Fi"
        default:
            return rawValue.uppercased()
        }
    }
}

extension SimCtl.StatusBar.WifiMode {
    var displayName: String {
        rawValue.capitalized
    }
}

extension SimCtl.StatusBar.CellularMode {
    var displayName: String {
        switch self {
        case .notSupported:
            return "Not Supported"
        default:
            return rawValue.capitalized
        }
    }
}
