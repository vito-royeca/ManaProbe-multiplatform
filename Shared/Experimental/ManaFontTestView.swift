//
//  ManaFontTestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 9/3/26.
//

import SwiftUI
import ManaKit

struct ManaFontTestView: View {
    @State
    private var fonts: [String: [String:String]] = [:]
    
    var body: some View {
        VStack {
            Text("Fonts: \(fonts.count)")
            List(fonts.keys.sorted(), id: \.self) { key in
                let dict = fonts[key]
                let name = dict?["name"] ?? ""
                let unicode = dict?["unicode"] ?? ""
                
                LabeledContent(content: {
                    Text(unicode.toSetUnicode())
                        .font(Font.custom("Mana", size: 30))
                }, label: {
                    Text("\(key) (\(name)) &#x\(unicode);")
                })
            }
            .onAppear {
                fonts = loadFonts()
            }
        }
    }
}

extension ManaFontTestView {
    func loadFonts() -> [String: [String:String]] {
        do {
            if let data = try! ManaKitUtilities.shared.read(from: nil,
                                                     or: "mana",
                                                            ofType: "plist") {
                
                let decoder = PropertyListDecoder()
                let dict = try decoder.decode([String: [String:String]].self, from: data)
                return dict
            }
        } catch {
            print(error)
        }
    
        return [:]
    }
}

#Preview {
    ManaFontTestView()
}
