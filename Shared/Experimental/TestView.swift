//
//  TestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/15/26.
//

import SwiftUI
import ManaKit

struct TestView: View {
    enum Flavor: String, CaseIterable, Identifiable {
        case chocolate, vanilla, strawberry
        var id: Self { self }
    }


    @State private var selectedFlavor: Flavor = .chocolate
    @State private var includesToppings: Bool = false
    @State private var quantity: Int = 1

    var body: some View {
        Menu("Ice Cream Order 3") {
            Button("Special request") {
                // Create a special request.
            }
            
            Toggle("Include toppings", isOn: $includesToppings)
                .menuActionDismissBehavior(.disabled)
            
            Picker("Flavor", selection: $selectedFlavor) {
                Text("🟤")
                    .tag(Flavor.chocolate)
                Text("⚪️")
                    .tag(Flavor.vanilla)
                Text("🔴")
                    .tag(Flavor.strawberry)
            }
            .pickerStyle(.palette)
            
            Stepper(value: $quantity) {
                Text("Quantity: \(quantity)")
            }
        }
    }
}

#Preview {
    TestView()
}
