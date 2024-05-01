//
//  stickersView.swift
//  Fianal
//
//  Created by Nora Aldossary on 22/10/1445 AH.
//

import SwiftUI

struct Sticker: Identifiable {
    var id = UUID()
    var imageName: String
    var position: CGSize
    var size: CGSize = CGSize(width: 100, height: 100)
    var rotation: Angle = .zero
    var isResizing: Bool = false
}

struct stickersView: View {
    var body: some View {
        stikcersView()
    }
}

struct stikcersView: View {
    @State private var droppedStickers: [Sticker] = []

    var body: some View {
        VStack {
            HStack {
                StickerBoard { sticker in
                    droppedStickers.append(Sticker(id: sticker.id, imageName: sticker.imageName, position: .zero))
                }
            }
        }
    }
}

struct StickerBoard: View {
    var onTapGesture: ((Sticker) -> Void)?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 32) {
                ForEach(stickers) { sticker in
                    Image(sticker.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .onTapGesture {
                            onTapGesture?(sticker)
                        }
                        .padding(.vertical, 10)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}


#Preview {
    stickersView()
}

extension StickerBoard {
    var stickers: [Sticker] {
        [
            Sticker(id: UUID(), imageName: "100", position: .zero),
            Sticker(id: UUID(), imageName: "butterfly", position: .zero),
            Sticker(id: UUID(), imageName: "cake", position: .zero),
            Sticker(id: UUID(), imageName: "celebrate", position: .zero),
            Sticker(id: UUID(), imageName: "cheers", position: .zero),
            Sticker(id: UUID(), imageName: "haha", position: .zero),
            Sticker(id: UUID(), imageName: "lol", position: .zero),
            Sticker(id: UUID(), imageName: "loveit", position: .zero),
            Sticker(id: UUID(), imageName: "nice", position: .zero),
            Sticker(id: UUID(), imageName: "pin", position: .zero),
            Sticker(id: UUID(), imageName: "pointing", position: .zero),
            Sticker(id: UUID(), imageName: "smile", position: .zero),
            Sticker(id: UUID(), imageName: "topSecret", position: .zero),
            Sticker(id: UUID(), imageName: "wow", position: .zero),
            Sticker(id: UUID(), imageName: "yes", position: .zero)
        ]
    }
}
