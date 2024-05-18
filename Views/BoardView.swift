import SwiftUI
import CloudKit
import UserNotifications

struct BoardView: View {
    var boardID: String
    var ownerNickname: String
    var title: String
    @Environment(\.presentationMode) var presentationMode // Added Environment property

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
    @State private var imageToDelete: BoardImage? = nil
    @State private var creationDate: Date? = nil
    @State private var timeRemaining: TimeInterval = 2
    @State private var timer: Timer? = nil
    @State private var isTimeUp = false
    @State private var showSaveAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GrayLight")
                    .ignoresSafeArea()
                    .gesture(TapGesture().onEnded {
                        if !isTimeUp {
                            selectedStickyNoteID = nil
                            stickerToDelete = nil
                            imageToDelete = nil
                        }
                    })

                ForEach(stickyNotes) { stickyNote in
                    if !isTimeUp {
                        StickyNoteView(stickyNote: stickyNote)
                            .gesture(TapGesture().onEnded {
                                selectedStickyNoteID = stickyNote.id  // Select the sticky note on tap
                                selectedStickerID = nil  // Deselect any sticker
                                stickerToDelete = nil
                                imageToDelete = nil
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
                    } else {
                        StickyNoteView(stickyNote: stickyNote)
                            .disabled(true)
                    }
                }
                
                displayBoardImages()  // Display board images first

                ForEach($stickers) { $sticker in
                    if (!isTimeUp) {
                        displaySticker(sticker: $sticker)  // Display stickers last
                    } else {
                        displaySticker(sticker: $sticker)
                            .disabled(true)
                    }
                }
                
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
                
                if let imageToDelete = imageToDelete {
                    VStack {
                        Text("🗑️")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.5))  // Adjust opacity to 0.7
                            .clipShape(Circle())
                            .onTapGesture {
                                deleteBoardImage(imageToDelete)
                                self.imageToDelete = nil  // Hide the delete icon after deletion
                            }
                    }
                    .position(imageToDelete.position)
                }
                
                VStack {
                    Text("⌛️ \(formattedTimeRemaining())")
                        .font(.headline)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.top, 10)
                    Spacer()
                }
            }

            .onAppear(perform: setupView)
            .navigationBarTitle(title, displayMode: .inline)
            
            .navigationBarItems(leading: backButton(), trailing: trailingButtons())
            .toolbar { if !isTimeUp { toolbarItems() } }
            .overlay(popoverOverlay(), alignment: .center)
            .overlay(membersListOverlay().padding(.bottom, 44)) // Add padding to avoid toolbar overlap
            .sheet(isPresented: $isImagePickerPresented, onDismiss: loadSelectedImage) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .alert(isPresented: $showSaveAlert) {
                Alert(title: Text("Success"), message: Text("Board image saved to Photo Album"), dismissButton: .default(Text("OK")))
            }
            
            if isTimeUp {
                VStack {
                    Button(action: {
                        exportBoardAsImage()
                    }) {
                        Text("Export")
                            .font(.body)
                            .padding()
                            .background(Color("MainColor"))
                            .foregroundColor(Color("GrayLight"))
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    private func formattedTimeRemaining() -> String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func setupView() {
        loadMembers()
        loadStickyNotes()
        loadBoardImages()
        fetchStickers()
        fetchCreationDate()
        startTimer()
        NotificationManager.shared.requestAuthorization()
    }
    
    private func fetchCreationDate() {
        BoardManager.shared.fetchBoardByBoardID(boardID) { result in
            switch result {
            case .success(let board):
                if let creationDate = board["boardCreationDate"] as? Date {
                    self.creationDate = creationDate
                    self.timeRemaining = self.timeRemaining(from: creationDate)

                    // فترات زمنية: 12 ساعة، 23 ساعة، 24 ساعة
                    let intervals: [TimeInterval] = [12 * 60 * 60, 23 * 60 * 60, 24 * 60 * 60]

                    for (index, interval) in intervals.enumerated() {
                        if let creationDate = self.creationDate {
                            let now = Date()
                            let timeElapsed = now.timeIntervalSince(creationDate)

                            if timeElapsed < interval {
                                let timeInterval = interval - timeElapsed
                                let notificationBody: String
                                switch index {
                                case 0:
                                    notificationBody = "It’s been 12 hours.. "
                                case 1:
                                    notificationBody = "Hey! Hurry up, you have 59 minutes ⏳"
                                case 2:
                                    notificationBody = "A lot of memories are here! Let’s save it! 📩"
                                default:
                                    notificationBody = ""
                                }
                                print("Scheduling notification: \(notificationBody) in \(timeInterval) seconds")
                                NotificationManager.shared.scheduleNotification(
                                    title: title,
                                    body: notificationBody,
                                    timeInterval: timeInterval,
                                    identifier: "\(boardID)_\(interval)_reminder"
                                )
                            } else {
                                print("Time elapsed (\(timeElapsed) seconds) is greater than or equal to the interval (\(interval) seconds)")
                            }
                        }
                    }
                } else {
                    print("Creation date is nil")
                }
            case .failure(let error):
                print("Failed to fetch creation date: \(error)")
            }
        }
    }






    private func scheduleNotificationForMember(_ member: String, interval: TimeInterval, identifierSuffix: String) {
        let notificationTitle = "Reminder"
        let notificationBody = "\(member), \(Int(interval / 60)) minutes have passed since you joined the board. Don't forget to check your tasks!"
        NotificationManager.shared.scheduleNotification(
            title: notificationTitle,
            body: notificationBody,
            timeInterval: interval,
            identifier: "\(boardID)_\(identifierSuffix)_\(member)"
        )
    }


    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let creationDate = self.creationDate else { return }
            self.timeRemaining = self.timeRemaining(from: creationDate)
            if self.timeRemaining == 0 {
                self.isTimeUp = true
                self.timer?.invalidate() // Stop the timer
            }
        }
    }

    private func timeRemaining(from creationDate: Date) -> TimeInterval {
        let now = Date()
        let timeElapsed = now.timeIntervalSince(creationDate)
        let timeRemaining = (24 * 60 * 60) - timeElapsed // 24 hours in seconds
        return max(timeRemaining, 0) // Ensure it doesn't go below 0
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
                    imageToDelete = nil
                })
                .gesture(LongPressGesture()
                    .onEnded { _ in
                        stickerToDelete = sticker.wrappedValue
                        imageToDelete = nil
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
                        let minScale: CGFloat = 0.50  // الحد الأدنى للحجم
                        let maxScale: CGFloat = 2.0  // الحد الأقصى للحجم
                        sticker.wrappedValue.scale = min(max(value, minScale), maxScale)  // تقييد الحجم بين الحد الأدنى والأقصى
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
    
    private func backButton() -> some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
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
            HStack {
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
            .background(Color("GrayLight")) // Match the main view's background color
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
        ForEach(boardImages.indices, id: \.self) { index in
            let boardImage = $boardImages[index]
            ZStack {
                GeometryReader { geometry in
                    Image(uiImage: boardImage.image.wrappedValue)
                        .resizable()
                        .scaledToFill()  // استخدام scaledToFill لضبط الصورة لتغطية الإطار
                        .frame(width: boardImage.frameSize.wrappedValue.width, height: boardImage.frameSize.wrappedValue.height)
                        .clipped()  // قص الصورة لتناسب الإطار
                        .cornerRadius(10)
                        .gesture(TapGesture().onEnded {
                            imageToDelete = boardImage.wrappedValue
                            stickerToDelete = nil
                        })
                        .gesture(DragGesture()
                            .onChanged { value in
                                // احسب الموضع الجديد بالنسبة لموضع البداية
                                let newX = boardImage.position.wrappedValue.x + value.translation.width
                                let newY = boardImage.position.wrappedValue.y + value.translation.height
                                let newLocation = CGPoint(x: newX, y: newY)
                                boardImage.position.wrappedValue = newLocation
                            }
                            .onEnded { value in
                                saveBoardImagePosition(boardImage.wrappedValue)
                            }
                        )
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                let minFrameSize: CGFloat = 150  // تحديد الحد الأدنى للحجم
                                let maxFrameSize: CGFloat = 400  // تحديد الحد الأقصى للحجم
                                let newSize = boardImage.frameSize.wrappedValue.width * value
                                boardImage.frameSize.wrappedValue = CGSize(
                                    width: min(max(newSize, minFrameSize), maxFrameSize),
                                    height: min(max(newSize, minFrameSize), maxFrameSize)
                                )
                            }
                            .onEnded { _ in
                                saveBoardImageSize(boardImage.wrappedValue)
                            }
                        )
                        .zIndex(1)
                }
                .frame(width: boardImage.frameSize.wrappedValue.width, height: boardImage.frameSize.wrappedValue.height)
                .position(boardImage.position.wrappedValue)
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
        let initialScale: CGFloat = 0.90 // تعيين الحجم الابتدائي للستيكر
        newSticker.position = CGPoint(x: randomX, y: randomY)
        newSticker.scale = initialScale
        
        DispatchQueue.main.async {
            self.stickers.append(newSticker)
            self.showStickers = false
        }
        
        // حفظ الستيكر الجديد في CloudKit
        StickerManager.shared.saveStickerBatch(newSticker, boardID: boardID) { result in
            switch result {
            case .success(let savedSticker):
                print("Sticker saved successfully: \(savedSticker)")
                if let index = stickers.firstIndex(where: { $0.id == newSticker.id }) {
                    stickers[index] = savedSticker  // تحديث الستيكر المحلي مع recordID المحفوظ
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
    
    private func deleteBoardImage(_ boardImage: BoardImage) {
        BoardImageManager.shared.deleteBoardImage(boardImage) { result in
            switch result {
            case .success():
                if let index = boardImages.firstIndex(where: { $0.id == boardImage.id }) {
                    boardImages.remove(at: index)
                }
                self.imageToDelete = nil  // Hide the delete icon after deletion
            case .failure(let error):
                print("Failed to delete board image: \(error)")
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
    
    private func exportBoardAsImage() {
        let image = takeScreenshotOfBoardContents()
        saveImageToPhotos(image)
    }

    private func takeScreenshotOfBoardContents() -> UIImage {
        let hostingController = UIHostingController(rootView: boardContentsView())
        let view = hostingController.view
        let targetSize = hostingController.sizeThatFits(in: UIScreen.main.bounds.size)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }

    private func boardContentsView() -> some View {
        ZStack {
            ForEach(boardImages) { boardImage in
                Image(uiImage: boardImage.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: boardImage.frameSize.width, height: boardImage.frameSize.height)
                    .clipped()
                    .position(boardImage.position)
            }

            ForEach(stickyNotes) { stickyNote in
                StickyNoteView(stickyNote: stickyNote)
                    .position(stickyNote.position)
                    .scaleEffect(stickyNote.scale)
            }

            ForEach(stickers) { sticker in
                Image(uiImage: sticker.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(sticker.scale)
                    .frame(width: 150 * sticker.scale, height: 150 * sticker.scale)
                    .position(sticker.position)
            }
        }
    }

    private func saveImageToPhotos(_ image: UIImage) {
        let imageSaver = ImageSaver(onSuccess: {
            showSaveAlert = true
        }, onError: { error in
            errorMessage = "Failed to save image: \(error.localizedDescription)"
        })
        UIImageWriteToSavedPhotosAlbum(image, imageSaver, #selector(ImageSaver.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardID: "12345", ownerNickname: "Alice", title: "Weekly Planning")
    }
}
