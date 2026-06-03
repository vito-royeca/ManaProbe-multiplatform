//
//  CardsNavigatorDelegate.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/28/26.
//

import Foundation

import ManaKit

protocol CardsNavigatorDelegate {
    var selectedCard: InnerCardInfo? { get set }
    var cardsArray: [InnerCardInfo] { get }
    var hasPrevious: Bool { get }
    var hasNext: Bool { get }
    func updateNavigation()
    func goToPrevious()
    func goToNext()
    
}


