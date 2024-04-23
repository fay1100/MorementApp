//
//  CreateBoardView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 11/10/1445 AH.
//
import SwiftUI

struct CreateBoardView: View {
    @State private var boardName = ""
    @State private var selectedDate = Date()
    @State private var isDatePickerShown = false
    @State private var selectedThumbnail: String? = nil
    @State private var showImagePicker = false

    let thumbnails = ["upload","thumbnail1", "thumbnail2", "thumbnail3" ]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Name of the board", text: $boardName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    

                ZStack {
                    TextField("Select Date", text: .constant(""), onEditingChanged: { editing in
                        if editing {
                            isDatePickerShown = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                    if isDatePickerShown {
                        Color.clear
                            .onTapGesture {
                                isDatePickerShown = false
                            }

                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden() // Hide labels of DatePicker
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }

                Text("Select thumbnail")
                    .padding()

                LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(thumbnails, id: \.self) { thumbnail in
                        if thumbnail == "upload" {
                            Menu {
                                Button("Browse") {
                                }
                                Button("Photo Library") {
                                }
                                Button("Take Photo") {
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 171, height: 103)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("GrayLight"), lineWidth: 1)
                                    )
                            }
                        } else {
                            Button(action: {
                                selectedThumbnail = thumbnail
                            }) {
                                Image(thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 171, height: 103)
                                    .cornerRadius(8)
                                    .overlay(                                  RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedThumbnail == thumbnail ? Color.blue : Color("GrayLight"), lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Text("When you create a board, you can share it with others to express your feelings and share special moments.")
                    .padding(.vertical, 70.0)


            }
            .navigationBarTitleDisplayMode(.inline) // Show title in the center
            .navigationTitle("Create New Board") // Title of the navigation bar
            .navigationBarItems(leading:
                Button("Cancel") {
                    // Action for cancel button
                },
                trailing:
                Button("Done") {
                    // Action for create button
                }
            )
            .accentColor(Color("MainColor"))
        }
    }
}

#if DEBUG
struct CreateBoardView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBoardView()
    }
}
#endif
