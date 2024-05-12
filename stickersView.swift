//
//  stickersView.swift
//  Fianal
//
//  Created by Nora Aldossary on 22/10/1445 AH.
//
import SwiftUI


struct Sticker: Identifiable, Hashable {
    var id = UUID()
    var imageName: String = "placeholder_image" // Default image name
    var position: CGSize = .zero
    var size: CGSize = CGSize(width: 100, height: 100)
    var rotation: Angle = .zero
    var isResizing: Bool = false

    // Implement hash function if you need custom behavior
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        // Add any other properties here if they contribute to the identity of the sticker
    }

    static func == (lhs: Sticker, rhs: Sticker) -> Bool {
        lhs.id == rhs.id
        // Compare other properties if they are part of the identity
    }
}
struct NoteViewWithGesture: View {
    @Binding var note: NoteModel

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(note.noteColor)
                .frame(width: 150, height: 150)
                .offset(x: note.position.x, y: note.position.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Temporarily update the position during drag
                            let newLocation = CGPoint(x: note.position.x + value.translation.width,
                                                      y: note.position.y + value.translation.height)
                            note.position = newLocation
                        }
                        .onEnded { value in
                            // Permanently update the position when the drag ends
                            let newLocation = CGPoint(x: note.position.x + value.translation.width,
                                                      y: note.position.y + value.translation.height)
                            note.position = newLocation
                        }
                )
            TextField("", text: $note.noteText)
                .foregroundColor(note.textColor)
                .font(.title)
                .padding()
                .frame(width: 150, height: 150)
                .background(Color.clear)
        }
    }
}

struct StickerBoard: View {
    
    @Binding var navigateToBoardView: Bool
    @Binding var droppedStickers: [Sticker]
    @State private var selectedSticker: Sticker?

    let stickers: [Sticker] = [
        Sticker(imageName: "100", position: .zero),
        Sticker(imageName: "butterfly", position: .zero),
        // Add more stickers...
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 32) {
                    ForEach(stickers) { sticker in
                        
                        
                        NavigationLink(destination: {
                            BoardView(addStickere: sticker)
                            
                            
                        }, label: {
                            
                                Image(sticker.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .padding(.vertical, 10)
                        }
                        
                        )
                            
                       
                        
                        
                    }
                }
                
            }
//            .navigationDestination(for: Sticker.self) { sticker in
//                BoardView(droppedStickers: $droppedStickers)
//                
//              
//                
//                
//            
//            }
            .onChange(of: selectedSticker) { newValue in
                if newValue != nil {
                    droppedStickers.append(newValue!)
                }
                
            }
            
        }
        
        
        
        
    }
    
  
}


struct StickerBoard_Previews: PreviewProvider {
    static var previews: some View {
        // إنشاء بيانات مؤقتة للمعاينة
        let droppedStickers = [
            Sticker(imageName: "example1"),
            Sticker(imageName: "example2")
        ]
        
        // استخدام Binding.constant لتوفير ربط مؤقت
        // تحديد النوع بشكل صريح لكل ربط
        StickerBoard(navigateToBoardView: Binding<Bool>.constant(false), droppedStickers: Binding<[Sticker]>.constant(droppedStickers))
    }
}
