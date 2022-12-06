//
//  ZoneMoreOptions.swift
//  NorthernLights
//
//  Created by Craig Vella on 12/4/22.
//

import Foundation
import SwiftUI

struct ZoneMoreOptions : View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var zones : Zones
    @EnvironmentObject var btc : BTConnection
    
    @State var showNameChange = false
    @State var showZoneDelete = false
    @State var previousName = ""
    @State var newSliderValue : Double = 0
    
    var zoneIndex : Int
    
    var body : some View {
        VStack {
            Spacer()
                .frame(height: 30)
            HStack (spacing: -25) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
                    .onTapGesture {
                        showZoneDelete = true
                    }
                    .alert("Delete Zone '\((zones.zones[zoneIndex]?.zoneName ?? "Deleted") )'? ", isPresented: $showZoneDelete) {
                        Button(action:{}) {
                            Text("Cancel").foregroundColor(.red)
                        }
                        Button("Delete") {
                            //zones.removeZone(zone: zones.zones[zoneIndex])
                            zones.zones.removeValue(forKey: zoneIndex)
                            btc.BTSendDataToWR(data: zones.serialize())
                            dismiss()
                        }
                    }
                Text(zones.zones[zoneIndex]?.zoneName ?? "Deleted")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                Image(systemName: "pencil").onTapGesture {
                    previousName = zones.zones[zoneIndex]?.zoneName ?? "Deleted"
                    showNameChange = true
                }
                .alert("Change Name", isPresented: $showNameChange) {
                    TextField("Name", text: $previousName).onChange(of: previousName) { _ in
                        previousName = String(previousName.prefix(Int(Zones.ZONE_NAME_SIZE)-1))
                    }
                    Button(action:{}) {
                        Text("Cancel").foregroundColor(.red)
                    }
                    Button("Save") {
                        zones.zones[zoneIndex]?.zoneName = previousName
                    }
                }
            }
            Text("Zone \((zones.zones[zoneIndex]?.zoneID ?? 0) + 1) - Additional Options")
            ColorPicker("Light Color", selection: zones.binding(for: zoneIndex).color, supportsOpacity: false)
            HStack{
                Text("Brightness - " + Int(((newSliderValue/255) * 100).rounded()).description + "%")
                Slider(value: $newSliderValue, in: 0...255, step: 1, label: {
                    Label("Brightness", systemImage: "lightbulb")
                }) {edit in
                    if !edit {
                        zones.zones[zoneIndex]?.brightness = newSliderValue
                    }
                }
            }
            Stepper(value: zones.binding(for: zoneIndex).ledCount, in: 0...255) {
                Text("LED Count - " + Int(zones.zones[zoneIndex]?.ledCount ?? 0).description)
            }
            Button("Close") {
                dismiss()
            }
            .font(.title2)
            Spacer()
        }
        .padding(20)
        .onAppear(){
            newSliderValue = zones.zones[zoneIndex]?.brightness ?? 0
        }
    }
}

struct ZoneMoreOptions_Preview : PreviewProvider {
    static var previews: some View {
        let z = Zones(zoneArray: [0:ZoneLighting(ZoneID: 0, ZoneName: "TestZone")])
        let btc = BTConnection(ZoneObject: z, Debug: true)
        ZoneMoreOptions(zoneIndex: 0)
            .environmentObject(z)
            .environmentObject(btc)
    }
}

