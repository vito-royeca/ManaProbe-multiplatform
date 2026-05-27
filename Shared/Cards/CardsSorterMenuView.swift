//
//  CardsSorterMenuView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/29/26.
//

import SwiftUI

struct CardsSorterMenuView: View {
    @AppStorage("CardsSorter")
    private var sorter = CardsSorter.defaultValue
    
    @Bindable
    var viewModel: CardsViewModel
    
    var body: some View {
        sortByMenu
    }
    
    private var sortByMenu: some View {
        Menu {
            ForEach(CardsSorter.allCases, id:\.description) { sorter in
                Button {
                    sortBy(sorter: sorter)
                } label: {
                    if self.sorter == sorter {
                        Label(sorter.description,
                              systemImage: "checkmark")
                    } else {
                        Text(sorter.description)
                    }
                }
            }
        } label: {
            Label("Sort by\n\(viewModel.sorter.description)",
                  systemImage: "arrow.up.arrow.down")
        }
    }
}

extension CardsSorterMenuView {
    func sortBy(sorter: CardsSorter) {
        viewModel.sorter = sorter
        viewModel.formatData()
    }
}

#Preview {
    let viewModel = CardsViewModel()
    CardsSorterMenuView(viewModel: viewModel)
}
