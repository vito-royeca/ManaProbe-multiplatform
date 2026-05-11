//
//  SetsSorterMenuView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/13/26.
//

import SwiftUI

struct SetsSorterMenuView: View {
    @Bindable
    var viewModel: SetsViewModel
    
    @AppStorage("SetsSorter")
    private var sorter = SetsSorter.defaultValue

    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        Menu {
            ForEach(SetsSorter.allCases, id:\.description) { sorter in
                Button {
                    self.sorter = sorter
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

extension SetsSorterMenuView {
    func sortBy(sorter: SetsSorter) {
        viewModel.sorter = sorter
        viewModel.formatData()
    }
}

#Preview {
    let viewModel = SetsViewModel()
    SetsSorterMenuView(viewModel: viewModel)
}
