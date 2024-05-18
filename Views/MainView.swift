import SwiftUI
import CloudKit

struct MainView: View {
    @State private var nickname: String = ""
    @State private var isLoading = true
    @State private var navigatingToBoardCreation = false
    @State private var showingJoinBoard = false
    @State private var errorMessage: String?
    @State private var boards: [(record: CKRecord, image: UIImage?)] = []
    @State private var showingDeleteAlert = false
    @State private var selectedBoard: (record: CKRecord, image: UIImage?)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    VStack {
                        Divider()
                            .offset(x: geometry.size.width * 0.0, y: geometry.size.height * -0.01)
                        
                        let welcomeText = Text("Welcome, \(nickname)!")
                            .fontWeight(.bold)
                        
                        let normalText = Text("\nWhat moments will you cherish today?")
                            .fontWeight(.regular)
                            .font(.system(size: 16))
                        
                        (welcomeText + normalText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .bold()
                            .offset(x: geometry.size.width * -0.10, y: geometry.size.height * -0.01)
                        
                        Spacer()
                        
                        if isLoading {
                            ProgressView().scaleEffect(1.5, anchor: .center)
                        } else if boards.isEmpty {
                            emptyStateView
                        } else {
                            boardsList
                        }
                    }
                }
                .onAppear {
                    fetchUserProfile()
                    fetchBoards()
                }
                .navigationBarItems(
                    trailing: HStack {
                        Button(action: {
                            showingJoinBoard = true
                        }) {
                            Image(systemName: "person.2")
                                .foregroundColor(Color("MainColor"))
                        }
                        Button(action: {
                            navigatingToBoardCreation = true
                        }) {
                            Image(systemName: "plus.rectangle")
                                .foregroundColor(Color("MainColor"))
                        }
                    }
                )
                .navigationBarBackButtonHidden(true)
                .navigationTitle("Boards")
                .fullScreenCover(isPresented: $navigatingToBoardCreation) {
                    BoardCreationView()
                        .transition(.move(edge: .trailing))
                }
                .overlay(
                    Group {
                        if showingJoinBoard {
                            JoinBoardView(nickname: $nickname, isShowingPopover: $showingJoinBoard)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .transition(.scale)
                        }
                    }, alignment: .center
                )
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete your profile?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteUserProfile()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .background(
                NavigationLink(
                    destination: BoardView(boardID: selectedBoard?.record["boardID"] as? String ?? "Unknown",
                                           ownerNickname: extractOwnerNickname(from: selectedBoard?.record ?? CKRecord(recordType: "Board")),
                                           title: selectedBoard?.record["title"] as? String ?? "Unnamed Board"),
                    isActive: Binding(
                        get: { selectedBoard != nil },
                        set: { if !$0 { selectedBoard = nil } }
                    )
                )
                { EmptyView() }
            )
        }
    }

    private var emptyStateView: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .center) {
                    Image("Empty")

                    Text("Start designing your boards by creating a new board")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .multilineTextAlignment(.center)
                    
                }
                .padding()
            }
            .offset(x: geometry.size.width * 0.0, y: geometry.size.height * 0.07)
        }
    }

    var boardsList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(boards, id: \.record.recordID) { board in
                    boardCard(for: board)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
        .refreshable {
            fetchBoards()
        }
    }

    func boardCard(for board: (record: CKRecord, image: UIImage?)) -> some View {
        Button(action: {
            selectedBoard = board // Set the selected board to trigger navigation
        }) {
            VStack {
                if let image = board.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 130)
                        .clipped()
                        .offset(y: -10)
                        .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
                        .background(Color.white)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 130)
                        .cornerRadius(10)
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .offset(y: -10)
                }
                Text(board.record["title"] as? String ?? "Unnamed Board")
                    .font(.system(size: 19))
                    .foregroundColor(.black)
                Text(dateToString(board.record.creationDate ?? Date()))
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(height: 20)
            }
            .background(Color("GrayLight"))
            .cornerRadius(10)
            .frame(width: 170, height: 218)
        }
        .contextMenu {
            Button(action: {
                deleteBoard(boardID: board.record["boardID"] as? String ?? "")
            }) {
                Label("Delete Board", systemImage: "trash")
            }
        }
    }

    var deleteProfileButton: some View {
        Button("Delete Profile") {
            showingDeleteAlert = true
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
    }

    func fetchUserProfile() {
        isLoading = true
        UserProfileManager.shared.fetchUserProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedNickname):
                    if let nickname = fetchedNickname {
                        self.nickname = nickname
                        print("Fetched nickname: \(nickname)")
                    } else {
                        errorMessage = "No profile exists, please create one."
                        print("No profile found")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("Error fetching profile: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteBoard(boardID: String) {
        isLoading = true
        BoardManager.shared.handleBoardDeletion(boardID: boardID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success():
                    self.boards.removeAll { $0.record["boardID"] as? String ?? "" == boardID }
                    print("Board deleted successfully.")
                case .failure(let error):
                    self.errorMessage = "Failed to delete board: \(error.localizedDescription)"
                }
            }
        }
    }

    func deleteUserProfile() {
        UserProfileManager.shared.deleteUserProfile(nickname: nickname) { result in
            switch result {
            case .success():
                print("Profile deleted successfully.")
                nickname = ""
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("Error deleting profile: \(error.localizedDescription)")
            }
        }
    }

    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func extractOwnerNickname(from record: CKRecord) -> String {
        (record["owner"] as? CKRecord.Reference)?.recordID.recordName ?? "Unknown"
    }

    func fetchBoards() {
        isLoading = true
        var fetchedBoards: [(record: CKRecord, image: UIImage?)] = []
        
        let group = DispatchGroup()
        
        group.enter()
        BoardManager.shared.fetchBoards { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let boardData):
                    fetchedBoards.append(contentsOf: boardData)
                case .failure(let error):
                    errorMessage = "Error fetching owned boards: \(error.localizedDescription)"
                }
                group.leave()
            }
        }
        
        group.enter()
        BoardManager.shared.fetchBoardsForCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let boardData):
                    fetchedBoards.append(contentsOf: boardData)
                case .failure(let error):
                    errorMessage = "Error fetching boards as member: \(error.localizedDescription)"
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.boards = fetchedBoards.sorted { $0.record.creationDate ?? Date.distantPast > $1.record.creationDate ?? Date.distantPast }
            self.isLoading = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
