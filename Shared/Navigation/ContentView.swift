//
//  ContentView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 11/10/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import ManaKit

struct ContentView: View {
    #if os(visionOS)
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment
    #endif
    
    var body: some View {
        #if os(visionOS)
        Group {
            switch player.presentation {
            case .fullWindow:
//                PlayerView()
//                    .immersiveEnvironmentPicker {
//                        ImmersiveEnvironmentPickerView()
//                    }
//                    .onAppear {
//                        player.play()
//                    }
                Text("Fullscreen view")
            default:
                ManaGuideTabs()
            }
        }
        #else
        ManaGuideTabs()
//            .presentVideoPlayer()
        #endif
    }
}

#Preview {
    ContentView()
}
