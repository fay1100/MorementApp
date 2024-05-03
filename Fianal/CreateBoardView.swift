//
//  CreateBoardView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 11/10/1445 AH.
//

import SwiftUI

struct CreateBoardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var boardName = ""
    @State private var selectedDate = Date()
    @State private var isDatePickerShown = false
    @State private var selectedThumbnail: String? = nil
    @State private var showImagePicker = false
    @State private var showImage = ""

    @EnvironmentObject var viewModel: BoardViewModel

    let thumbnails = ["upload", "thumbnail1", "thumbnail2", "thumbnail3"]

    var body: some View {
        NavigationStack {
            VStack {
                // Image view with conditional content
                if showImage.isEmpty {
                    Image(systemName: "photo.on.rectangle") // Placeholder icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 171, height: 130)
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GrayLight"), lineWidth: 1)
                        )
                } else {
                    Image(showImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFit()
                        .frame(width: 171, height: 130)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GrayLight"), lineWidth: 1)
                        )
                }

                TextField("Name of the board", text: $boardName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("Select thumbnail")
                    .padding()

                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 140, maximum: 250)), count: 2), spacing: 16) {
                    ForEach(thumbnails, id: \.self) { thumbnail in
                        if thumbnail == "upload" {
                            Menu {
                                Button("Browse") {
                                    // Implement file browsing
                                }
                                Button("Photo Library") {
                                    // Implement photo library selection
                                }
                                Button("Take Photo") {
                                    // Implement camera access
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()

                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 171, height: 130)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("GrayLight"), lineWidth: 1)
                                    )
                            }
                        } else {
                            Button(action: {
                                selectedThumbnail = thumbnail
                                showImage = thumbnail
                            }) {
                                Image(thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 171, height: 130)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedThumbnail == thumbnail ? Color.blue : Color("GrayLight"), lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Text("When you create a board, you can share it with others to express your feelings and share special moments.")
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create New Board")
            .navigationBarItems(leading:
                Button("Cancel") {
                    dismiss()
                }, trailing:
                Button("Done") {
                    if let thumbnail = selectedThumbnail, !boardName.isEmpty {
                        viewModel.createBoard(name: boardName, image: thumbnail)
                    }
                    dismiss()
                }
            )
            .accentColor(Color("MainColor"))
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct CreateBoardView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBoardView().environmentObject(BoardViewModel())
    }
}

//import SwiftUI
//
//
//struct CreateBoardView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var boardName = ""
//    @State private var selectedDate = Date()
//    @State private var isDatePickerShown = false
//    @State private var selectedThumbnail: String? = nil
//    @State private var showImagePicker = false
//    @State private var showImage = " "
//
//    @EnvironmentObject var viewModel: BoardViewModel // Use the shared view model
//
//    let thumbnails = ["upload", "thumbnail1", "thumbnail2", "thumbnail3"]
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Image(showImage.isEmpty ? "placeholder" : showImage)
//                
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 171, height: 103)
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color("GrayLight"), lineWidth: 1)
//                    )
//
//                TextField("Name of the board", text: $boardName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                Text("Select thumbnail")
//                    .padding()
//
//                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 110, maximum: 200)), count: 2), spacing: 16) {
//                    ForEach(thumbnails, id: \.self) { thumbnail in
//                        if thumbnail == "upload" {
//                            Menu {
//                                Button("Browse") {
//                                    // Implement file browsing
//                                }
//                                Button("Photo Library") {
//                                    // Implement photo library selection
//                                }
//                                Button("Take Photo") {
//                                    // Implement camera access
//                                }
//                            } label: {
//                                Image(systemName: "square.and.arrow.up")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 171, height: 103)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(Color("GrayLight"), lineWidth: 1)
//                                    )
//                            }
//                        } else {
//                            Button(action: {
//                                selectedThumbnail = thumbnail
//                                showImage = thumbnail
//                            }) {
//                                Image(thumbnail)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 171, height: 103)
//                                    .cornerRadius(8)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(selectedThumbnail == thumbnail ? Color("MainColor") : Color("GrayLight"), lineWidth: 2)
//                                    )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                }
//                Text("When you create a board, you can share it with others to express your feelings and share special moments.")
//                    .padding()
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("Create New Board")
//            .navigationBarItems(leading:
//                Button("Cancel") {
//                    dismiss()
//                }, trailing:
//                Button("Done") {
//                    if let thumbnail = selectedThumbnail, !boardName.isEmpty {
//                        viewModel.createBoard(name: boardName, image: thumbnail)
//                    }
//                    dismiss()
//                }
//            )
//            .accentColor(Color("MainColor"))
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//}

//struct CreateBoardView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var boardName = ""
//    @State private var selectedDate = Date()
//    @State private var isDatePickerShown = false
//    @State private var selectedThumbnail: String? = nil
//    @State private var showImagePicker = false
//    @State private var showImage = ""
//
//
//    @EnvironmentObject var viewModel: BoardViewModel // Use the shared view model
//
//    
//    let thumbnails = ["upload","thumbnail1", "thumbnail2", "thumbnail3" ]
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Image(showImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 171, height: 103)
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color("GrayLight"), lineWidth: 1))
//
//                TextField("Name of the board", text: $boardName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                Text("Select thumbnail")
//                    .padding()
//
//                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 110, maximum: 190)), count: 2), spacing: 16) {
//
//                    ForEach(thumbnails, id: \.self) { thumbnail in
//                        if thumbnail == "upload" {
//                            Menu {
//                                Button("Browse") {
//                                }
//                                Button("Photo Library") {
//                                }
//                                Button("Take Photo") {
//                                }
//                            } label: {
//                                Image(systemName: "square.and.arrow.up")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 171, height: 103)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(Color("GrayLight"), lineWidth: 1)
//                                    )
//                            }
//                        } else {
//                            Button(action: {
//                                selectedThumbnail = thumbnail
//                                showImage = thumbnail
//                            }) {
//                                Image(thumbnail)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 171, height: 103)
//                                    .cornerRadius(8)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(selectedThumbnail == thumbnail ? Color("MainColor") : Color("GrayLight"), lineWidth: 2)
//                                    )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                }
//                Text("When you create a board, you can share it with others to express your feelings and share special moments.")
//                    .padding()
//
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("Create New Board")
//            .navigationBarItems(leading:
//                Button("Cancel") {
//                    dismiss()
//                },
//                trailing:
//                Button("Done") {
//                if let thumbnail = selectedThumbnail {
//                    viewModel.createBoard(name: boardName, image: thumbnail)
//                }
//                    dismiss()
//                }
//            )
//            .accentColor(Color("MainColor"))
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//    
//    func createBoard() {
//
//
//    }
//}
//
//
//#if DEBUG
//struct CreateBoardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateBoardView()
//    }
//}
//#endif
