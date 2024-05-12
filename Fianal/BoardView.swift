import SwiftUI


struct BoardView: View {
    //@Binding
    
    @State var addStickere: Sticker
   // @Binding
    @State  var droppedStickers: [Sticker] = []
    @State private var notes: [NoteModel] = []
    @State private var selectedNote: NoteModel?
    @State private var showNoteToolbar = false
    @State private var isDragging = false
    @State private var currentScale: CGFloat = 1.0
    @State private var showCustomMenu = false
    @State private var navigateToStickersView = false

//    public init(droppedStickers: Binding<[Sticker]>,addStickere: Binding<Sticker>) {
//        self._droppedStickers = droppedStickers
//        self._addStickere = addStickere
//
//    }
    
//    public init(addStickere: Binding<Sticker>) {
//      //  self._droppedStickers = droppedStickers
//        self._addStickere = addStickere
//
//    }

    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        Color("GrayLight").ignoresSafeArea()
                        ForEach($droppedStickers) { $sticker in
                            Image(sticker.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: sticker.size.width * currentScale, height: sticker.size.height * currentScale)
                                .position(x: sticker.position.width, y: sticker.position.height)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            sticker.position.width += value.translation.width
                                            sticker.position.height += value.translation.height
                                        }
                                        .onEnded { _ in
                                            isDragging = false
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

                        ScrollView([.horizontal, .vertical]) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach($notes, id: \.id) { $note in
                                    NoteViewWithGesture(note: $note)
                                        .frame(width: note.size.width, height: note.size.height)
                                        .position(x: note.position.x, y: note.position.y)
                                        .onTapGesture {
                                            selectedNote = note
                                            showNoteToolbar = true
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                Spacer()
                if let note = selectedNote, showNoteToolbar {
                    NoteToolbar(notes: $notes, note: $selectedNote)
                        .padding(.top, 20)
                } else {
                    ToolbarView(addNoteAction: addNewNote, showCustomMenu: $showCustomMenu, navigateToStickersView: $navigateToStickersView, droppedStickers: $droppedStickers)
                        .padding(.top, 20)
                }
            }
            
            .background(Color("GrayLight"))
            .navigationTitle("My Friends' Gathering")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .all)
            .onAppear {
                
                droppedStickers.append(addStickere)
            }
        }
    }

    func addNewNote() {
        let newNote = NoteModel(
            noteText: "New Note",
            noteColor: Color.random,
            textColor: .white,
            position: CGPoint.zero,
            size: CGSize(width: 100, height: 100)
        )
        notes.append(newNote)
        selectedNote = nil
    }
}

extension Color {
    static var random: Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}
struct NoteViewWithGesturre: View {
    @Binding var note: NoteModel
    @GestureState private var dragState = CGSize.zero
    @GestureState private var magnifyState = CGFloat(1.0)

    var body: some View {
        Text(note.noteText)
            .frame(width: note.size.width * magnifyState, height: note.size.height * magnifyState)
            .background(note.noteColor)
            .foregroundColor(note.textColor)
            .cornerRadius(10)
            .position(x: note.position.x + dragState.width, y: note.position.y + dragState.height)
            .gesture(
                DragGesture()
                    .updating($dragState) { (value, state, _) in
                        state = value.translation
                    }
                    .onEnded { value in
                        note.position.x += value.translation.width
                        note.position.y += value.translation.height
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .updating($magnifyState) { (value, state, _) in
                        state = value
                    }
                    .onEnded { value in
                        note.size.width *= value
                        note.size.height *= value
                    }
            )
    }
}
struct BoardView_Previews: PreviewProvider {
    @State static var stickers = [Sticker()] 
    @State static var addstickers = Sticker() // Initial sticker data for previews
    
    static var previews: some View {
        BoardView(addStickere: addstickers, droppedStickers: stickers)
    }
}
