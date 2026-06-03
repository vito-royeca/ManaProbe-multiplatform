//
//  CardsNavigatorToolbar.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/28/26.
//

import SwiftUI

struct CardsNavigatorToolbar: ToolbarContent {
    var navigatorDelegate: CardsNavigatorDelegate
    var displayDelegate: CardsNavigatorDisplayDelegate
    var placement: ToolbarItemPlacement = .topBarTrailing
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: placement) {
            Button {
                navigatorDelegate.goToPrevious()
                if let card = navigatorDelegate.selectedCard {
                    Task {
                        await displayDelegate.display(card: card)
                    }
                }
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(!navigatorDelegate.hasPrevious)
            
            Button {
                navigatorDelegate.goToNext()
                if let card = navigatorDelegate.selectedCard {
                    Task {
                        await displayDelegate.display(card: card)
                    }
                }
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(!navigatorDelegate.hasNext)
        }
    }
}
