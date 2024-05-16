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
    @State private var stickerToDelete: Sticker? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GrayLight")
                    .ignoresSafeArea()
                    .gesture(TapGesture().onEnded {
                        selectedStickyNoteID = nil
                        stickerToDelete = nil
                    })
                
                ForEach(stickyNotes) { stickyNote in
                    StickyNoteView(stickyNote: stickyNote)
                        .gesture(TapGesture().onEnded {
                            selectedStickyNoteID = stickyNote.id  // Select the sticky note on tap
                            selectedStickerID = nil  // Deselect any sticker
                            stickerToDelete = nil
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
                ForEach($stickers) { $sticker in
                    displaySticker(sticker: $sticker)
                }
 
                
                displayBoardImages()  // Display board images separately
                
                displayStickerGridView()
                
                if let stickerToDelete = stickerToDelete {
                    VStack {
                        Text("🗑️")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.5))  // Adjust opacity to 0.7
                            .clipShape(Circle())

                            .onTapGesture {
                                deleteSticker(stickerToDelete)
                                self.stickerToDelete = nil  // Hide the delete icon after deletion
                            }
                    }
                    .position(stickerToDelete.position)
                }
            }
            .onAppear(perform: setupView)
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: backButton(), trailing: trailingButtons())
            .toolbar { toolbarItems() }
            .overlay(popoverOverlay(), alignment: .center)
            .overlay(membersListOverlay())
            .sheet(isPresented: $isImagePickerPresented, onDismiss: loadSelectedImage) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }

        }
    }
    
    private func displaySticker(sticker: Binding<Sticker>) -> some View {
        ZStack {
            Image(uiImage: sticker.wrappedValue.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(sticker.wrappedValue.scale)
                .frame(width: 150 * sticker.wrappedValue.scale, height: 150 * sticker.wrappedValue.scale)
                .background(Color.clear)  // لضمان عدم وجود خلفية
                .cornerRadius(15)
                .position(sticker.wrappedValue.position)
                .gesture(TapGesture().onEnded {
                    selectedStickerID = sticker.wrappedValue.id
                    selectedStickyNoteID = nil
                    stickerToDelete = nil  // إخفاء أيقونة الحذف عند النقر على الملصق
                })
                .gesture(LongPressGesture()
                    .onEnded { _ in
                        stickerToDelete = sticker.wrappedValue
                    }
                )
                .gesture(DragGesture()
                    .onChanged { value in
                        sticker.wrappedValue.position = value.location
                    }
                    .onEnded { _ in
                        saveStickerPosition(sticker.wrappedValue)
                    }
                )
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        sticker.wrappedValue.scale = value
                    }
                    .onEnded { _ in
                        saveStickerPosition(sticker.wrappedValue)
                    }
                )
                .zIndex(1)  // لضمان ظهور الملصق فوق العناصر الأخرى
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
        loadBoardImages()
        fetchStickers()
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
                        // Remove from CloudKit
                        StickyNoteManager.shared.deleteStickyNote(stickyNotes[index]) { result in
                            switch result {
                            case .success():
                                // Remove from local array
                                stickyNotes.remove(at: index)
                                self.selectedStickyNoteID = nil
                            case .failure(let error):
                                print("Failed to delete sticky note: \(error)")
                            }
                        }
                    },
                    onBold: {
                        stickyNotes[index].isBold.toggle()  // Toggle bold state
                    }
                )
            } else {
                ToolbarView(showStickers: $showStickers, addStickyNote: addStickyNoteToBoard, isImagePickerPresented: $isImagePickerPresented)
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
                GeometryReader { geometry in
                    Image(uiImage: boardImage.image)
                        .resizable()
                        .scaledToFill()  // استخدام scaledToFill لضبط الصورة لتغطية الإطار
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()  // قص الصورة لتناسب الإطار
                        .cornerRadius(10)
                        .gesture(DragGesture()
                            .onChanged { value in
                                boardImage.position = value.location
                            }
                            .onEnded { _ in
                                saveBoardImagePosition(boardImage)
                            }
                        )
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                let minFrameSize: CGFloat = 150  // تحديد الحد الأدنى للحجم
                                let maxFrameSize: CGFloat = 400  // تحديد الحد الأقصى للحجم
                                let newSize = boardImage.frameSize.width * value
                                boardImage.frameSize = CGSize(
                                    width: min(max(newSize, minFrameSize), maxFrameSize),
                                    height: min(max(newSize, minFrameSize), maxFrameSize)
                                )
                            }
                            .onEnded { _ in
                                saveBoardImageSize(boardImage)
                            }
                        )
                        .zIndex(1)
                }
                .frame(width: boardImage.frameSize.width, height: boardImage.frameSize.height)
                .position(boardImage.position)
            }
        }
    }

    private func saveBoardImagePosition(_ boardImage: BoardImage) {
        BoardImageManager.shared.saveBoardImageBatch(boardImage, boardID: boardID) { result in
            switch result {
            case .success(let savedImage):
                print("Board image position saved successfully: \(savedImage)")
                if let index = boardImages.firstIndex(where: { $0.id == savedImage.id }) {
                    boardImages[index] = savedImage  // Update the local board image with the saved recordID
                }
            case .failure(let error):
                print("Failed to save board image position: \(error)")
            }
        }
    }

    private func saveBoardImageSize(_ boardImage: BoardImage) {
        BoardImageManager.shared.saveBoardImageBatch(boardImage, boardID: boardID) { result in
            switch result {
            case .success(let savedImage):
                print("Board image size saved successfully: \(savedImage)")
                if let index = boardImages.firstIndex(where: { $0.id == savedImage.id }) {
                    boardImages[index] = savedImage  // Update the local board image with the saved recordID
                }
            case .failure(let error):
                print("Failed to save board image size: \(error)")
            }
        }
    }

    private func addStickerToBoard(sticker: Sticker) {
        var newSticker = sticker
        let randomX = CGFloat.random(in: 50...300)
        let randomY = CGFloat.random(in: 100...600)
        newSticker.position = CGPoint(x: randomX, y: randomY)
        
        DispatchQueue.main.async {
            self.stickers.append(newSticker)
            self.showStickers = false
        }
        
        // Save the new sticker to CloudKit
        StickerManager.shared.saveStickerBatch(newSticker, boardID: boardID) { result in
            switch result {
            case .success(let savedSticker):
                print("Sticker saved successfully: \(savedSticker)")
                if let index = stickers.firstIndex(where: { $0.id == newSticker.id }) {
                    stickers[index] = savedSticker  // Update the local sticker with the saved recordID
                }
            case .failure(let error):
                print("Failed to save sticker: \(error)")
            }
        }
    }

    private func addStickyNoteToBoard() {
        let randomX = CGFloat.random(in: 50...300)  // تحديد نطاق للإحداثيات العشوائية X
        let randomY = CGFloat.random(in: 100...600)  // تحديد نطاق للإحداثيات العشوائية Y

        let newStickyNote = StickyNote(
            text: "",
            position: CGPoint(x: randomX, y: randomY),
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
    
    private func saveStickerPosition(_ sticker: Sticker) {
        StickerManager.shared.saveStickerBatch(sticker, boardID: boardID) { result in
            switch result {
            case .success(let updatedSticker):
                if let index = stickers.firstIndex(where: { $0.id == updatedSticker.id }) {
                    stickers[index] = updatedSticker
                }
            case .failure(let error):
                print("Failed to save sticker position: \(error)")
            }
        }
    }
    
    private func deleteSticker(_ sticker: Sticker) {
        StickerManager.shared.deleteSticker(sticker) { result in
            switch result {
            case .success():
                if let index = stickers.firstIndex(where: { $0.id == sticker.id }) {
                    stickers.remove(at: index)
                }
                self.stickerToDelete = nil  // Hide the delete icon after deletion
            case .failure(let error):
                print("Failed to delete sticker: \(error)")
            }
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
    
    private func loadBoardImages() {
        isLoading = true
        BoardImageManager.shared.fetchBoardImages(forBoardID: boardID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let images):
                    self.boardImages = images
                case .failure(let error):
                    self.errorMessage = "Failed to load board images: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadSelectedImage() {
        guard let selectedImage = selectedImage else { return }
        
        let defaultSize: CGFloat = 200
        let newBoardImage = BoardImage(
            image: selectedImage,
            position: CGPoint(x: 100, y: 100),
            frameSize: CGSize(width: defaultSize, height: defaultSize)
        )
        boardImages.append(newBoardImage)
        
        // Save the new board image to CloudKit
        BoardImageManager.shared.saveBoardImageBatch(newBoardImage, boardID: boardID) { result in
            switch result {
            case .success(let savedImage):
                print("Board image saved successfully: \(savedImage)")
                if let index = boardImages.firstIndex(where: { $0.id == newBoardImage.id }) {
                    boardImages[index] = savedImage  // Update the local board image with the saved recordID
                }
            case .failure(let error):
                print("Failed to save board image: \(error)")
            }
        }
    }

    private func fetchStickers() {
        isLoading = true
        StickerManager.shared.fetchStickers(forBoardID: boardID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let stickers):
                    self.stickers = stickers
                case .failure(let error):
                    self.errorMessage = "Failed to load stickers: \(error.localizedDescription)"
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
