import SwiftUI

struct BoardView: View {
    @Binding var inputImage: UIImage?
    @State var addSticker: Sticker
    @State var droppedStickers: [Sticker] = []
    @State private var stickerPositions: [UUID: CGSize] = [:]
    
    @State private var notes: [NoteModel] = []
    @State private var selectedNote: NoteModel?
    @State private var showNoteToolbar = false
    @State private var currentScale: CGFloat = 1.0
    @State private var showCustomMenu = false
    @State private var navigateToStickersView = false
    @State private var remainingTime = 86400  // 24 hours in seconds
    @State private var participantCount = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(formatTime(remainingTime))
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.orange)
                        .padding([.leading, .top], 10)
                    
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.orange)
                        .padding(.top, 10)
                    
                    Text("\(participantCount)")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.orange)
                }
                .padding(.top, 140)
                
                GeometryReader { geometry in
                    ZStack {
                        Color("GrayLight").ignoresSafeArea()
                        ForEach($droppedStickers) { $sticker in
                            Image(sticker.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: sticker.size.width * currentScale, height: sticker.size.height * currentScale)
                                .position(x: geometry.size.width / 2 + (stickerPositions[sticker.id]?.width ?? 0),
                                          y: geometry.size.height / 2 + (stickerPositions[sticker.id]?.height ?? 0))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            stickerPositions[sticker.id] = CGSize(width: value.translation.width, height: value.translation.height)
                                        }
                                        .onEnded { value in
                                            let finalPosition = CGSize(width: (stickerPositions[sticker.id]?.width ?? 0) + value.translation.width,
                                                                       height: (stickerPositions[sticker.id]?.height ?? 0) + value.translation.height)
                                            stickerPositions[sticker.id] = finalPosition
                                            currentScale = 1.0  // Reset scale after dragging
                                        }
                                )
                                .simultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { scale in
                                            currentScale = scale
                                        }
                                        .onEnded { scale in
                                            sticker.size.width *= scale
                                            sticker.size.height *= scale
                                            currentScale = 1.0
                                        }
                                )
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                Spacer()
                if let _ = selectedNote, showNoteToolbar {
                    NoteToolbar(notes: $notes, note: $selectedNote)
                        .padding(.top, 20)
                } else {
                    ToolbarView(addNoteAction: addNewNote, showCustomMenu: $showCustomMenu, navigateToStickersView: $navigateToStickersView, droppedStickers: $droppedStickers, inputImage: $inputImage)
                        .padding(.top, 20)
                }
            }
            .background(Color("GrayLight"))
            .navigationTitle("My Friends' Gathering")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .all)
            .onAppear {
                droppedStickers.append(addSticker)
            }
            .onReceive(timer) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                }
            }
        }
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func addNewNote() {
        withAnimation {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let initialSize = CGSize(width: 300, height: 200)
            let centerPositionX = screenWidth / 2 - initialSize.width / 2
            let centerPositionY = screenHeight / 2 - initialSize.height / 2
            
//            let newNote = NoteModel(
////                noteText: "New Note",
////                noteColor: Color.random,
//                textColor: .white,
//                position: CGPoint(x: centerPositionX, y: centerPositionY),
//                size: initialSize
////            )
//            notes.append(newNote)
//            selectedNote = nil
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(inputImage: .constant(nil), addSticker: Sticker(imageName: "defaultImageName"))
    }
}
