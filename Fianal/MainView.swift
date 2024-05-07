//
//  MainView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 11/10/1445 AH.
//
//
import SwiftUI

struct Board: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var image: String
}

class BoardViewModel: ObservableObject {
    @Published var boards: [Board] = []

    func createBoard(name: String, image: String) {
        let newBoard = Board(name: name, image: image)
        boards.insert(newBoard, at: 0)
    }
}

struct MainView: View {
    @EnvironmentObject var viewModel: BoardViewModel
    @State private var selectedBoard: Board?
    @State private var editingBoardID: UUID?
    @State private var temporaryName: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.boards.isEmpty {
                    emptyStateView
                } else {
                    boardsGridView
                }
            }
            .navigationBarTitle("Boards")
            .navigationBarItems(trailing: navigationBarItems)
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .center) {
            Image("Empty")
            Text("Start designing your boards by creating a new board")
                .foregroundColor(Color.gray.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var boardsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.boards) { board in
                    boardView(for: board)
                }
            }
            .padding()
        }
    }

    private func boardView(for board: Board) -> some View {
        VStack(alignment: .leading) {
            Image(board.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 171, height: 130)
                .clipped()

            HStack {
                if editingBoardID == board.id {
                    TextField("Enter new name", text: $temporaryName, onCommit: {
                        finishEditing(board: board)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .vertical], 8)
                } else {
                    Text(board.name)
                        .padding([.leading, .vertical], 8)
                }
                Spacer()
                boardActionsMenu(board: board)
            
            }.padding()
            .background(Color.grayLight)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.grayLight, lineWidth: 1)
        )
    }

    private func boardActionsMenu(board: Board) -> some View {
        Menu {
            Button("Rename") {
                temporaryName = board.name
                editingBoardID = board.id
            }
            Button("Share") {
                // Placeholder for sharing functionality
            }
            Button("Delete") {
                selectedBoard = board
                deleteBoard()
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }

    private func finishEditing(board: Board) {
        if let index = viewModel.boards.firstIndex(where: { $0.id == board.id }) {
            viewModel.boards[index].name = temporaryName
        }
        editingBoardID = nil
    }

    private func deleteBoard() {
        if let board = selectedBoard, let index = viewModel.boards.firstIndex(where: { $0.id == board.id }) {
            viewModel.boards.remove(at: index)
        }
    }

    private var navigationBarItems: some View {
        HStack {
            Button(action: {
//
            }) {
                Image(systemName: "person.2")
            }
            NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
                Image(systemName: "plus.rectangle")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(BoardViewModel())
    }
}







// نسخ قديمه 
//import SwiftUI
//
//struct Board: Identifiable, Hashable {
//    let id = UUID()
//    var name: String
//    var image: String
//}
//class BoardViewModel: ObservableObject {
//    @Published var boards: [Board] = []
//
//    func createBoard(name: String, image: String) {
//        let newBoard = Board(name: name, image: image)
//        boards.insert(newBoard, at: 0)
//    }
//}
//
//struct MainView: View {
//    @EnvironmentObject var viewModel: BoardViewModel
//    @State private var selectedBoard: Board?
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if viewModel.boards.isEmpty {
//                    emptyStateView
//                } else {
//                    boardsGridView
//                }
//            }
//            .navigationBarTitle("Boards")
//            .navigationBarItems(trailing: navigationBarItems)
//        }
//    }
//
//    private var emptyStateView: some View {
//        VStack(alignment: .center) {
//            Image("Empty")
//            Text("Start designing your boards by creating a new board")
//                .foregroundColor(Color("GrayMid"))
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//    }
//
//    private var boardsGridView: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                ForEach(viewModel.boards) { board in
//                    boardView(for: board)
//                }
//            }
//            .padding()
//        }
//    }
//
//    private func boardView(for board: Board) -> some View {
//        VStack(alignment: .leading) {
//            Image(board.image)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 171, height: 103)
//                .clipped()
//            
//            HStack {
//                Text(board.name)
//                    .padding([.leading, .vertical], 8)
//                Spacer()
//                boardActionsMenu(board: board)
//
//            }.padding()
//            .background(Color.grayLight)
//            .frame(minWidth: 0, maxWidth: .infinity)
//        }
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.grayLight, lineWidth: 1)
//        )
//    }
//
//
//    private func boardActionsMenu(board: Board) -> some View {
//        Menu {
//            Button("Rename") {
//                selectedBoard = board
//                renameBoard()
//            }
//            Button("Share") {
////
//            }
//            Button("Delete") {
//                selectedBoard = board
//                deleteBoard()
//            }
//        } label: {
//            Image(systemName: "ellipsis")
//        }
//    }
//
//    private func renameBoard() {
//
//    }
//
//
//    private func deleteBoard() {
//        // Code to delete `selectedBoard` from your boards array
//        if let board = selectedBoard, let index = viewModel.boards.firstIndex(where: { $0.id == board.id }) {
//            viewModel.boards.remove(at: index)
//        }
//    }
//
//    
//    
//    private var navigationBarItems: some View {
//        HStack {
//            Button(action: {
//            }) {
//                Image(systemName: "plus.magnifyingglass")
//            }
//            NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
//                Image(systemName: "rectangle.badge.plus")
//            }
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(BoardViewModel())
//    }
//}

//import SwiftUI
//
//struct Board: Identifiable, Hashable {
//    let id = UUID()
//    var name: String
//    var image: String
//}
//
//class BoardViewModel: ObservableObject {
//    @Published var boards: [Board] = []
//
//    func createBoard(name: String, image: String) {
//        let newBoard = Board(name: name, image: image)
//        boards.insert(newBoard, at: 0)  // Insert at the beginning to simulate a stack
//    }
//}
//
//struct MainView: View {
//    @EnvironmentObject var viewModel: BoardViewModel
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if viewModel.boards.isEmpty {
//                    emptyStateView
//                } else {
//                    boardsGridView
//                }
//            }
//            .navigationBarTitle("Boards")
//            .navigationBarItems(trailing: navigationBarItems)
//        }
//    }
//
//    private var emptyStateView: some View {
//        VStack(alignment: .center) {
//            Image("Empty")
//            Text("Start designing your boards by creating a new board")
//                .foregroundColor(Color("GrayMid"))
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//    }
//
//    private var boardsGridView: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                ForEach(viewModel.boards.reversed()) { board in
//                    boardView(for: board)
//                }
//            }
//            .padding()
//        }
//    }
//
//    private func boardView(for board: Board) -> some View {
//        VStack {
//            Image(board.image)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 171, height: 103)
//                .cornerRadius(8)
//            HStack {
//                Text(board.name)
//                boardActionsMenu
//            }
//        }
//    }
//
//    private var boardActionsMenu: some View {
//        Menu {
//            Button("Rename") {
//                // Implement rename functionality
//            }
//            Button("Share") {
//                // Implement share functionality
//            }
//            Button("Delete") {
//                // Implement delete functionality
//            }
//        } label: {
//            Image(systemName: "ellipsis.circle")
//        }
//    }
//
//    private var navigationBarItems: some View {
//        HStack {
//            Button(action: {
//                // Implement add functionality
//            }) {
//                Image(systemName: "plus.magnifyingglass")
//            }
//            NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
//                Image(systemName: "rectangle.badge.plus")
//            }
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(BoardViewModel())
//    }
//}
/*

import SwiftUI

struct Board: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var image: String
}



class BoardViewModel: ObservableObject {
    @Published var boards: [Board] = []

    func createBoard(name: String, image: String) {
        let newBoard = Board(name: name, image: image)
        boards.insert(newBoard, at: 0)
    }
}


struct MainView: View {
    @EnvironmentObject var viewModel: BoardViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.boards.isEmpty {
                    // Display a message when no boards exist
                    VStack(alignment: .center) {
                        Image("Empty")
                        Text("Start designing your boards by creating a new board")
                            .foregroundColor(Color("GrayMid"))
                            .multilineTextAlignment(.center)
                    } .padding()
                }

                // Grid view to display boards
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 110, maximum: 190)), count: 2), spacing: 16) {
                    ForEach(viewModel.boards) { board in
                        VStack {
                            Image(board.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 171, height: 103)
                                .cornerRadius(8)
                            HStack{
                                Text(board.name)
                            Image(systemName:"pencil")
                                Menu {
                                    Button("Rename") {

                                    }
                                    Button("Share") {
                                    }
                                    Button("Delete") {
                                    }
                                }
                            }
                    }
                }
            }
            .navigationBarTitle("Board")
            .navigationBarItems(trailing: HStack {
                Button(action: {}) {
                    Image(systemName: "plus.magnifyingglass")
                }
                NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
                    Image(systemName: "rectangle.badge.plus")
                }
            })
        }
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(BoardViewModel())
    }
}
*/


//struct MainView: View {
//    @EnvironmentObject var viewModel: BoardViewModel
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if viewModel.boards.isEmpty {
//                    VStack(alignment: .center) {
//                        Image("Empty")
//                        Text("Start designing your boards by creating a new board")
//                            .foregroundColor(Color("GrayMid"))
//                            .multilineTextAlignment(.center)
//                    } .padding()
//                }
//
//                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 110, maximum: 190)), count: 2), spacing: 16) {
//                    ForEach(viewModel.boards) { board in
//                        VStack {
//                            Image(board.image)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 171, height: 103)
//                                .cornerRadius(8)
//                            Text(board.name)
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle("Board")
//            .navigationBarItems(trailing: HStack {
//                Button(action: {}) {
//                    Image(systemName: "plus.magnifyingglass")
//                }
//                NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
//                    Image(systemName: "rectangle.badge.plus")
//                }
//            })
//        
//        }
//    }
//}


//struct MainView: View {
//    @EnvironmentObject var viewModel: BoardViewModel
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // Show empty state only when no board is selected
//                if viewModel.selectedName.isEmpty && viewModel.selectedImage.isEmpty {
//                    VStack {
//                        Image("Empty") // Consider changing the image or hiding it depending on the context
//                        Text("Start designing your boards by creating a new board")
//                            .foregroundColor(Color("GrayMid"))
//                            .multilineTextAlignment(.center)
//                    }
//                }
//
//                // Show the selected board if available
//                if !viewModel.selectedName.isEmpty && !viewModel.selectedImage.isEmpty {
//                    VStack {
//                        Image(viewModel.selectedImage)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 171, height: 216)
//                            .cornerRadius(8)
//                        Text(viewModel.selectedName)
//                    }
//                }
//            }
//            .navigationBarTitle("Board")
//            .navigationBarItems(trailing: HStack {
//                Button(action: {
//                    
//                }) {
//                    Image(systemName: "plus.magnifyingglass")
//                }
//                NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
//                    Image(systemName: "rectangle.badge.plus")
//                }
//            })
//            .accentColor(Color("MainColor"))
//        }
//    }
//}
//

//
//class BoardViewModel: ObservableObject {
//    @Published var selectedName: String = ""
//    @Published var selectedImage: String = ""
//
//    func createBoard(name: String, image: String) {
//        self.selectedName = name
//        self.selectedImage = image
//    }
//}
//
//struct MainView: View {
//    @EnvironmentObject var viewModel: BoardViewModel 
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Image("Empty")
//                HStack(spacing: 10) {
//                    Text("Start designing your boards by creating a new board")
//                        .foregroundColor(Color("GrayMid"))
//                        .multilineTextAlignment(.center)
//                    
//                    if !viewModel.selectedName.isEmpty && !viewModel.selectedImage.isEmpty {
//                        VStack {
//                            Image(viewModel.selectedImage)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 171, height: 216)
//                                .cornerRadius(8)
//                            Text(viewModel.selectedName)
//                        }
//                    }
//                }
//                .navigationBarTitle("Board")
//                .navigationBarItems(trailing:
//                                        HStack {
//                    Button(action: {
//                        
//                    }) {
//                        Image(systemName: "plus.magnifyingglass")
//                    }
//                    Button(action: {
//                        
//                    }) {
//                        NavigationLink(destination: CreateBoardView().environmentObject(viewModel)) {
//                            Image(systemName: "rectangle.badge.plus")
//                        }
//                    }
//                })
//                .accentColor(Color("MainColor"))
//
//            }
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(BoardViewModel())
//    }
//}





//struct MainView: View {
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Image("Empty")
//                HStack(spacing: 10) {
//                    Text("Start designing your boards by creating a new board")
//                        .foregroundColor(Color("GrayMid"))
//                        .multilineTextAlignment(.center)
//
//                    if !selectedName.isEmpty && !selectedImage.isEmpty {
//                        VStack {
//                            Image(selectedImage)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 171, height: 216)
//                                .cornerRadius(8)
//                            Text(selectedName)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .navigationBarTitle("Board")
//            .navigationBarItems(trailing:
//                HStack {
//                    Button(action: {
//                    }) {
//                        Image(systemName: "plus.magnifyingglass")
//                    }
//                    Button(action: {
//
//                    }) {
//                        NavigationLink(destination: CreateBoardView()) {
//                            Image(systemName: "rectangle.badge.plus")
//                        }
//                    }
//                }
//            )
//            .accentColor(Color("MainColor"))
//        }
//    }
//}
//
//
//import SwiftUI
//
//struct MainView: View {
//    var body: some View {
//        NavigationStack  {
//            VStack {
//                Image("Empty")
//                HStack(spacing: 10) {
//                    Text("Start designing your boards by creating a new board")
//                        .foregroundColor(Color("GrayMid"))
//                        .multilineTextAlignment(.center)
////بنحط اللي قالته فوفو
//                    Image(systemName: "rectangle.badge.plus")
//                        .foregroundColor(Color("MainColor"))
//
//                }.padding(.horizontal)
//                
//            }
//            .navigationBarTitle("Board")
//            .navigationBarItems(trailing:
//                HStack {
//                    Button(action: {
//                        // Action for the first trailing button
//                    }) {
//                        Image(systemName: "plus.magnifyingglass")
//                    }
//                Button(action: {
//                    // Navigate to CreateBoardView when this button is tapped
//                    // Here, you add the navigation logic
//                    // For example, you can push the CreateBoardView onto the navigation stack
//                }) {
//                    NavigationLink(destination: CreateBoardView()) {
//                        Image(systemName: "rectangle.badge.plus")
//                    }
//                }
//            }
//            )
//            .accentColor(Color("MainColor"))
//
//        }
//    }
//}
//
//#if DEBUG
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
//#endif
