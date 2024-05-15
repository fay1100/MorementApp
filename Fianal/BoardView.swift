import SwiftUI
import CloudKit

struct BoardView: View {
    var boardID: String
    var ownerNickname: String
    var title: String
    
    @State private var showingPopover = false
    @State private var showStickers = false
    @State private var tempImage: UIImage?
    @State private var stickers: [Sticker] = []
    @State private var stickyNotes: [StickyNote] = []
    @State private var members: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var JoinBoardView = false
    @State private var showMembersList = false
    @State private var selectedStickerID: UUID? = nil
    @State private var selectedStickyNoteID: UUID? = nil
    @State private var boardImages: [BoardImage] = []
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GrayLight")
                    .ignoresSafeArea()
                    .gesture(TapGesture().onEnded {
                        selectedStickyNoteID = nil
                    })
                
                ForEach($stickers) { $sticker in
                    displaySticker(sticker: $sticker)
                }
                
                ForEach(stickyNotes) { stickyNote in
                    StickyNoteView(stickyNote: stickyNote)
                        .gesture(TapGesture().onEnded {
                            selectedStickyNoteID = stickyNote.id  // Select the sticky note on tap
                            selectedStickerID = nil  // Deselect any sticker
                        })
                        .gesture(DragGesture()
                            .onChanged { value in
                                var updatedNote = stickyNote
                                updatedNote.position = value.location
                                updateStickyNote(updatedNote)
                            }
                        )
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                var updatedNote = stickyNote
                                let minScale: CGFloat = 0.5  // Minimum scale
                                updatedNote.scale = max(value, minScale)  // Update the scale with a minimum limit
                                updateStickyNote(updatedNote)
                            }
                        )
                }
                
                displayBoardImages()  // Display board images separately
                
                displayStickerGridView()
            }
            .onAppear(perform: setupView)
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: backButton(), trailing: trailingButtons())
            .toolbar { toolbarItems() }
            .overlay(popoverOverlay(), alignment: .center)
            .overlay(membersListOverlay())
        }
    }
    
    private func displaySticker(sticker: Binding<Sticker>) -> some View {
        ZStack {
            Image(uiImage: sticker.wrappedValue.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(sticker.wrappedValue.scale)
                .frame(width: 150 * sticker.wrappedValue.scale, height: 150 * sticker.wrappedValue.scale)
                .cornerRadius(15)
                .position(sticker.wrappedValue.position)
                .gesture(TapGesture().onEnded {
                    selectedStickerID = sticker.wrappedValue.id
                    selectedStickyNoteID = nil
                })
                .gesture(DragGesture()
                    .onChanged { value in
                        sticker.wrappedValue.position = value.location
                    }
                )
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        let minScale: CGFloat = 0.5
                        sticker.wrappedValue.scale = max(value, minScale)
                    }
                )
            
            if selectedStickerID == sticker.wrappedValue.id {
                Button(action: {
                    if let index = stickers.firstIndex(where: { $0.id == sticker.wrappedValue.id }) {
                        stickers.remove(at: index)
                    }
                    selectedStickerID = nil
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .position(x: sticker.wrappedValue.position.x + 60, y: sticker.wrappedValue.position.y - 60)
            }
        }
    }

    private func displayStickerGridView() -> some View {
        Group {
            if showStickers {
                StickerGridView(selectSticker: { sticker in
                    self.addStickerToBoard(sticker: sticker)
                }, showStickers: $showStickers)
            }
        }
    }
    
    private func setupView() {
        loadMembers()
        loadStickyNotes()
    }
    
    private func backButton() -> some View {
        NavigationLink(destination: MainView()) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("MainColor"))
        }
    }
    
    private func trailingButtons() -> some View {
        HStack {
            Button(action: {
                showMembersList.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color("MainColor"))
            }
            
            Button(action: {
                showingPopover.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color("MainColor"))
            }
        }
    }
    
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            if let selectedStickyNoteID = selectedStickyNoteID,
               let index = stickyNotes.firstIndex(where: { $0.id == selectedStickyNoteID }) {
                StickyNoteToolbar(
                    stickyNote: stickyNotes[index],
                    onDelete: {
                        stickyNotes.remove(at: index)
                        self.selectedStickyNoteID = nil
                    },
                    onBold: {
                        stickyNotes[index].isBold.toggle()  // Toggle bold state
                    }
                )
            } else {
                ToolbarView(showStickers: $showStickers, addStickyNote: addStickyNoteToBoard)
            }
        }
    }
    
    private func popoverOverlay() -> some View {
        Group {
            if showingPopover {
                DetailsView(showingPopover: $showingPopover, boardID: boardID, ownerNickname: ownerNickname, title: title)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .transition(.move(edge: .top))
            }
        }
    }
    
    private func membersListOverlay() -> some View {
        Group {
            if showMembersList {
                MembersListView(members: members, adminNickname: ownerNickname)
                    .background(Color.white)
                    .cornerRadius(15)
                    .transition(.move(edge: .top))
                    .padding(.top, -345)
                    .padding(.trailing, -120)
            }
        }
    }
    
    private func displayBoardImages() -> some View {
        ForEach($boardImages) { $boardImage in
            ZStack {
                Image(uiImage: boardImage.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(boardImage.scale)
                    .frame(width: 150 * boardImage.scale, height: 150 * boardImage.scale)
                    .cornerRadius(15)
                    .position(boardImage.position)
                    .gesture(DragGesture()
                        .onChanged { value in
                            boardImage.position = value.location
                        }
                    )
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            let minScale: CGFloat = 0.5
                            boardImage.scale = max(value, minScale)
                        }
                    )
            }
        }
    }
    
    private func addStickerToBoard(sticker: Sticker) {
        var newSticker = sticker
        newSticker.scale = 1.0
        
        let randomX = CGFloat.random(in: 50...300)
        let randomY = CGFloat.random(in: 100...600)
        newSticker.position = CGPoint(x: randomX, y: randomY)
        
        DispatchQueue.main.async {
            self.stickers.append(newSticker)
            self.showStickers = false
        }
    }

    
    private func addStickyNoteToBoard() {
        let newStickyNote = StickyNote(
            text: "",
            position: CGPoint(x: 150, y: 150),
            scale: 1.0,
            color: .yellow
        )
        self.stickyNotes.append(newStickyNote)
        
        // Save the new sticky note to CloudKit
        StickyNoteManager.shared.saveStickyNoteBatch(newStickyNote, boardID: boardID) { result in
            switch result {
            case .success(let savedNote):
                print("Sticky note saved successfully: \(savedNote)")
                if let index = stickyNotes.firstIndex(where: { $0.id == newStickyNote.id }) {
                    stickyNotes[index] = savedNote  // Update the local sticky note with the saved recordID
                }
            case .failure(let error):
                print("Failed to save sticky note: \(error)")
            }
        }
    }

    
    private func updateStickyNote(_ stickyNote: StickyNote) {
        if let index = stickyNotes.firstIndex(where: { $0.id == stickyNote.id }) {
            stickyNotes[index] = stickyNote
            
            // Save the updated sticky note to CloudKit
            StickyNoteManager.shared.saveStickyNoteBatch(stickyNote, boardID: boardID) { result in
                switch result {
                case .success(let savedNote):
                    print("Sticky note updated successfully: \(savedNote)")
                    stickyNotes[index] = savedNote  // Update the local sticky note with the updated recordID
                case .failure(let error):
                    print("Failed to update sticky note: \(error)")
                }
            }
        } else {
            print("Sticky note with ID \(stickyNote.id) not found.")
        }
    }
    
    private func loadMembers() {
        isLoading = true
        BoardManager.shared.fetchBoardByBoardID(boardID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let boardRecord):
                    if let membersReferences = boardRecord["members"] as? [CKRecord.Reference] {
                        self.members = membersReferences.map { $0.recordID.recordName }
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load members: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadStickyNotes() {
        isLoading = true
        StickyNoteManager.shared.fetchStickyNotes(forBoardID: boardID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let notes):
                    self.stickyNotes = notes
                case .failure(let error):
                    self.errorMessage = "Failed to load sticky notes: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardID: "12345", ownerNickname: "Alice", title: "Weekly Planning")
    }
}
