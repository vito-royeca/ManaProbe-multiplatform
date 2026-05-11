//
//  AsyncPreviewView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/20/26.
//

import SwiftUI

struct AsyncPreviewView<VisualContent: View, ModelData>: View {
    var viewBuilder: (ModelData?) -> VisualContent
    var fetchData: () async throws -> ModelData?
    
    @State private var modelData: ModelData?
    @State private var error: Error?
    
    var body: some View {
        safeView
            .task {
                do {
                    self.modelData = try await fetchData()
                } catch {
                    self.error = error
                    print(error)
                }
            }
    }
    
    @ViewBuilder
    private var safeView: some View {
        if let modelData {
            viewBuilder(modelData)
        }
        else if let error {
            Text(error.localizedDescription)
                .foregroundStyle(Color.red)
        }
        else {
            Text("Calculating async data...")
        }
    }
}
