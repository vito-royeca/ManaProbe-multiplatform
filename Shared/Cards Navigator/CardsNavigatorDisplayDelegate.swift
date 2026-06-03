//
//  CardsNavigatorDisplayDelegate.swift
//  Manaprobe
//
//  Created by Vito Royeca on 6/3/26.
//

import Foundation

import ManaKit

protocol CardsNavigatorDisplayDelegate {
    func display(card: InnerCardInfo) async
}
