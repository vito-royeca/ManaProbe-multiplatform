//
//  CardsSearchViewModel.swift
//  ManaGuide
//
//  Created by Vito Royeca on 3/21/22.
//

import CoreData
import SwiftUI
import ManaKit

class CardsSearchViewModel: CardsViewModel {
    
    // MARK: - Variables

    static let maxPageSize = 20
    
    @Published var nameFilter = ""
//    @Published var raritiesFilter = [MGRarity]()
//    @Published var typesFilter = [MGCardType]()
//    @Published var keywordsFilter = [MGKeyword]()
//    @Published var artistsFilter = [MGArtist]()
    @Published var pageLimit = maxPageSize
    @Published var pageOffset = 0
    @Published var hasMoreData = true
    @Published var isLoadingNextPage = false


    // MARK: - Initializers

    // MARK: - Methods

    override func fetchRemoteData() async throws {
        guard !isBusy else {
            return
        }

        do {

            DispatchQueue.main.async {
                
            }

        } catch {
            DispatchQueue.main.async {
                self.isBusy = false
                self.isFailed = true
            }
        }
    }
}

