//
//  AuthModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/26/26.
//

import SwiftUI

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseFirestore
import FirebaseGoogleSwiftUI
import FirebaseOAuthSwiftUI
import FirebasePhoneAuthSwiftUI

struct FBUser: Identifiable, Codable {
    @DocumentID
    var id: String?
    var displayName: String?
    var photoURL: String?
    var email: String?
    var createdAt: String?
}

@MainActor
@Observable
class AuthModel {
    @ObservationIgnored
    let authService: AuthService
    
    @ObservationIgnored
    private var db = Firestore.firestore()

    var showAccountView: Bool = false
    var user: FBUser?
    
    init() {
        let actionCodeSettings = ActionCodeSettings()

        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.url = URL(string: "https://manaprobe-dev.firebaseapp.com ")
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.linkDomain = "manaprobe-dev.firebaseapp.com"
        let configuration = AuthConfiguration(
          shouldAutoUpgradeAnonymousUsers: true,
          customStringsBundle: .main,
//          tosUrl: URL(string: "https://manaprobe.com/"),
          privacyPolicyUrl: URL(string: "https://manaprobe.com/privacy.html"),
          emailLinkSignInActionCodeSettings: actionCodeSettings,
          mfaEnabled: true
        )

        authService = AuthService(
          configuration: configuration
        )
//        .withAppleSignIn()
//        .withPhoneSignIn()
        .withGoogleSignIn()
//        .withFacebookSignIn(FacebookProviderSwift())
    //    .withTwitterSignIn()
//        .withOAuthSignIn(OAuthProviderSwift.github())
    //    .withOAuthSignIn(OAuthProviderSwift.microsoft())
    //    .withOAuthSignIn(OAuthProviderSwift.yahoo())
    //    .withOAuthSignIn(
    //      OAuthProviderSwift(
    //        providerId: "oidc.line",
    //        scopes: ["openid", "profile", "email"],
    //        buttonLabel: "Sign in with LINE",
    //        displayName: "Line",
    //        buttonIcon: Image(.icLineLogo),
    //        buttonBackgroundColor: .lineButton,
    //        buttonForegroundColor: .white
    //      )
    //    )
//        .withEmailSignIn()
    }
    
    func initials(from name: String) -> String {
        let formatter = PersonNameComponentsFormatter()

        if let components = formatter.personNameComponents(from: name) {
             formatter.style = .abbreviated
             return formatter.string(from: components)
        } else {
            return name.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
        }
    }
    
    private func loadUser() async throws {
        guard let currentUser = authService.currentUser else {
            return
        }

        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let ref = db.collection("users").document(currentUser.uid)
            var doc = try await ref.getDocument()

            if !doc.exists {
                var data = [String: Any]()
                if let displayName = currentUser.displayName {
                    data["displayName"] = displayName
                }
                if let photoURL = currentUser.photoURL {
                    data["photoURL"] = photoURL.absoluteString
                }
                if let email = currentUser.email {
                    data["email"] = email
                }
                data["createdAt"] = formatter.string(for: currentUser.metadata.creationDate ?? Date())
                try await ref.setData(data)
                doc = try await ref.getDocument()
            }
            user = try doc.data(as: FBUser.self)
        } catch {
            throw error
        }
    }
    
    func handleState(state: AuthenticationState) async {
        if state != .authenticating {
          authService.isPresented = state == .unauthenticated
        }
        
        if state == .authenticated {
            do {
                try await loadUser()
            } catch {
                print(error)
            }
        } else if state == .unauthenticated {
            user = nil
        }
    }
}

