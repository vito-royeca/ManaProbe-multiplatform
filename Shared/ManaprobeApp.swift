//
//  ManaprobeApp.swift
//  Manaprobe
//
//  Created by Vito Royeca on 3/21/22.
//

import SwiftUI
import Firebase
import ManaKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ManaprobeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

    @Environment(\.scenePhase)
    var scenePhase

    #if os(visionOS)
    /// An object that stores the app's level of immersion.
    @State
    private var immersiveEnvironment = ImmersiveEnvironment()
    /// The content brightness to apply to the immersive space.
    @State
    private var contentBrightness: ImmersiveContentBrightness = .automatic
    /// The effect modifies the passthrough in immersive space.
    @State
    private var surroundingsEffect: SurroundingsEffect? = nil
    #endif
    
    init() {
        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask,
                                                           true)[0]
        print("docsPath = \(docsPath)")
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.accentColor)

        // ManaKit
        let apiURLEndpoint = Bundle.main.infoDictionary! ["API_URL_ENDPOINT"] as! String
        print("apiURLEndpoint = \(apiURLEndpoint)")
        ManaKitUtilities.shared.configure(apiURL: apiURLEndpoint)
        ManaKitUtilities.shared.loadCustomFonts()
        Task {
            await ManaKitUtilities.shared.downloadSymbolsFont()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(visionOS)
                .environment(immersiveEnvironment)
                #endif
            
                #if os(macOS)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                #endif
            
                // Set minimum window size
                #if os(macOS) || os(visionOS)
                .frame(minWidth: Constants.contentWindowWidth, maxWidth: .infinity, minHeight: Constants.contentWindowHeight, maxHeight: .infinity)
                #endif
            
                // Use a dark color scheme on supported platforms.
//                #if os(iOS) || os(macOS)
//                .preferredColorScheme(.dark)
//                #endif
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                print("App is active")
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in background")
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
        .commands {
            SidebarCommands()
        }
        
        #if !os(tvOS)
        .windowResizability(.contentSize)
        #endif
        
        #if os(visionOS)
        // Defines an immersive space to present a destination in which to watch the video.
        ImmersiveSpace(id: ImmersiveEnvironmentView.id) {
            ImmersiveEnvironmentView()
                .environment(immersiveEnvironment)
                .onAppear {
                    immersiveEnvironment.immersiveSpaceState = .open
                    contentBrightness = immersiveEnvironment.contentBrightness
                    surroundingsEffect = immersiveEnvironment.surroundingsEffect
                }
                .onDisappear {
                    immersiveEnvironment.immersiveSpaceState = .closed
                    contentBrightness = .automatic
                    surroundingsEffect = nil
                }
            // Apply a custom tint color for the video passthrough of a person's hands and surroundings.
                .preferredSurroundingsEffect(surroundingsEffect)
        }
        // Set the content brightness for the immersive space.
        .immersiveContentBrightness(contentBrightness)
        // Set the immersion style to progressive, so the user can use the Digital Crown to dial in their experience.
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        #endif
        
        
    }
}
