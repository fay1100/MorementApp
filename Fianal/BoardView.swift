import SwiftUI

struct BoardView: View {
    @State private var showingPopover = false
    var noteModel: NoteModel  // Assume NoteModel is defined correctly elsewhere
    
    @State private var isSelected = false  // Added state for selection

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GrayLight")  // Ensure this color is defined in your asset catalog
                    .ignoresSafeArea()

                VStack {
                    Text(noteModel.noteText)  // Display the text from the note
                        .font(.title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(noteModel.noteColor))
                        .foregroundColor(noteModel.textColor)
                        .multilineTextAlignment(noteModel.textAlignment)
                        .padding()
                        .rotationEffect(.degrees(isSelected ? 5 : 0)) // Rotation effect
                        .scaleEffect(isSelected ? 1.1 : 1.0) // Scale effect
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle() // Toggle selection
                            }
                        }

                    Spacer()
                }

                Divider()
                    .padding(.bottom, 700)
                
                VStack {
                    // Assuming ToolbarView is defined and correctly implemented
                    ToolbarView()
                        .padding(.top, 550)
                }
            }
            .navigationBarTitle("My Friends' Gathering", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // Action for back navigation
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("MainColor"))  // Ensure this color is defined
                },
                trailing: Button(action: {
                    showingPopover = true
                }) {
                    Text("Details")
                        .foregroundColor(Color("MainColor"))  // Ensure this color is defined
                }
            )
        }
        .overlay(
            Group {
                if showingPopover {
                    DetailsView(showingPopover: $showingPopover)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .transition(.move(edge: .top))
                }
            }, alignment: .center
        )
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(noteModel: NoteModel())  // Provide a dummy NoteModel for previews
    }
}
