//
//  RulesRowView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/21/26.
//

import SwiftUI
import ManaKit
import UniformTypeIdentifiers

struct RulesRowView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @State
    var term: String
    @State
    var definition: String
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        LabeledContent {
            VStack {
                AttributedText(
                    addColor(to: NSAttributedString(symbol: definition,
                                                    pointSize: 16),
                             colorScheme: colorScheme)
//                    NSAttributedString(symbol: definition,
//                                       pointSize: 16)
                )
                HStack {
                    Spacer()
                    shareButton
                }
            }
        } label: {
            Text(term)
        }
        .labeledContentStyle(.vertical)
    }
    
    var copyButton: some View {
        Button {
            UIPasteboard.general.string = "\(term)\n\n\(definition)"
        } label: {
            Image(systemName: "document.on.document")
                .tint(.accentColor)
        }
        
    }
    
    var shareButton: some View {
        let item = RuleTransferable(term: term, definition: definition)
        
        return ShareLink(item: item.message,
//                         subject: Text(item.subject),
//                         message: Text(item.message),
//                         preview: SharePreview(item.term, image: previewImage),
                         label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundStyle(Color.accentColor)
        })
    }
    
    var previewImage: Image {
        let systemUIImage = UIImage(systemName: "text.book.closed")!
            .resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30))
//            .withRenderingMode(.alwaysTemplate)
        let image = Image(uiImage: systemUIImage)
//            .renderingMode(.original)
//            .aspectRatio(contentMode: .fit)
//            .resizable()
//            .frame(width: 30, height: 30)
            
        return image
    }
}

struct RuleTransferable: Transferable {
    let title = "Magic: The Gathering Comprehensive Rules"
    let footer = "Shared from Manaprobe"
    
    public var term: String
    public var definition: String
    
    public var subject: String {
        "\(title) - \(term)"
    }
    public var message: String {
        "\(term)\n\n\(definition)\n\n------\n\n\(title)\n\n- \(footer)"
    }
    
    static var transferRepresentation: some TransferRepresentation {
//        DataRepresentation(contentType: .utf8PlainText) { rule in
//            rule.message.data(using: .utf8) ?? Data()
//        } importing: { data in
//            let content = String(decoding: data, as: UTF8.self)
//            let array = content.split(separator: "\n\n")
//            print("array 0: \(array[0])")
//            print("array 1: \(array[1])")
//            return RuleTransferable(term: String(array[0]),
//                                    definition: String(array[1]))
//        }
//        .suggestedFileName { item in
//            item.term
//        }
        
        FileRepresentation(exportedContentType: .plainText) { rule in
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(rule.term).appendingPathExtension("txt")
            let data = rule.message.data(using: .utf8) ?? Data()
            try data.write(to: fileURL)

            return SentTransferredFile(fileURL)
        }
        .suggestedFileName { item in
            item.term
        }

//        ProxyRepresentation(exporting: \.message)
//            .suggestedFileName { item in
//                item.term
//            }

    }
}

#Preview {
    RulesRowView(term: "LLanowar Elves",
                 definition: "{T}: Add {G}.")
}
