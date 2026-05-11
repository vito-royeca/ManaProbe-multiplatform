//
//  AccountToolbar.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/26/26.
//

import SwiftUI

import FirebaseAuth
import FirebaseAuthSwiftUI
import NukeUI

struct AccountToolbar: ToolbarContent {
    let placement: ToolbarItemPlacement
    
    @Environment(AuthModel.self)
    private var authModel
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button {
                authModel.showAccountView.toggle()
            } label: {
                avatarView
            }
        }
    }
    
    var avatarView: some View {
        Group {
            if authModel.authService.authenticationState == .authenticated {
                if let url = authModel.authService.currentUser?.photoURL {
                    LazyImage(url: url) { phase in
                        if let _ = phase.error {
                            Image(systemName: "photo.badge.exclamationmark")
                        } else if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            ProgressView()
                        }
                    }
                } else if let name = authModel.authService.currentUser?.displayName {
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
