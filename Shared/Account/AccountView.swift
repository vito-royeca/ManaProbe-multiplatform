//
//  AccountView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/26/26.
//

import SwiftUI

import FirebaseAppleSwiftUI
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseOAuthSwiftUI
import FirebasePhoneAuthSwiftUI
import NukeUI

struct AccountView: View {
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesModel
    
    @Environment(\.presentationMode)
    private var presentationMode

    var body: some View {
        AuthPickerView {
            contentView
        }
        .environment(authModel.authService)
    }
    
    var contentView: some View {
        NavigationStack {
            if authModel.authService.authenticationState == .unauthenticated {
                loginView
            } else {
                profileView
            }
        }
    }
    
    @ToolbarContentBuilder
    private var titleToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label : {
                Image(systemName: "xmark")
            }
        }
    }

    private var loginView: some View {
        VStack(spacing: 50) {
            Image("logoWords")
                .resizable()
                .frame(maxWidth: 256, maxHeight: 64)

            Text("You can do a lot of cool things in Manaprobe. However, you are currently not Signed in. Tap the button below to:")
            Spacer()
            Button {
                authModel.authService.isPresented = true
            } label: {
                Text("Sign in or Sign up")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .toolbar {
            titleToolbar
        }
    }
    
    private var profileView : some View {
        List {
            headerView
            NavigationLink(value: "") {
                Text("Favorite News")
            }
            NavigationLink(value: "Favorites") {
                Text("Favorite Cards")
            }
            NavigationLink(value: "Collections") {
                Text("Collections")
            }
            
            Section {
                Button {
                    authModel.authService.isPresented = true
                } label: {
                    Text("Manage Account")
                }
                .buttonStyle(.bordered)
                
                Button {
                    Task {
                        try? await authModel.authService.signOut()
                    }
                } label: {
                    Text("Sign Out")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .toolbar {
            titleToolbar
        }
        
    }
    
    var headerView: some View {
        HStack {
            avatarView
            Text(authModel.user?.displayName ?? "")
        }
    }

    var avatarView: some View {
        Group {
            if authModel.authService.authenticationState == .authenticated {
                if let urlString = authModel.user?.photoURL,
                   let url = URL(string: urlString) {
                    LazyImage(url: url) { phase in
                        if let _ = phase.error {
                            Image(systemName: "photo.badge.exclamationmark")
                        } else if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            ProgressView()
                        }
                    }
                } else if let name = authModel.user?.displayName {
                    Text(authModel.initials(from: name))
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                }
                
            } else {
                Image(systemName: "person.slash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environment(AuthModel())
            .environment(FavoritesViewModel())
    }
}
