import SwiftUI

enum ToolbarOption {
    case none
    case colorPicker
    case textColorPicker
    case boldText
}

class NoteModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var noteText: String
    @Published var noteColor: Color
    @Published var textColor: Color
    @Published var isBold: Bool
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var dragOffset: CGPoint  // Correctly declare the property

    init(noteText: String, noteColor: Color, textColor: Color, isBold: Bool = false, position: CGPoint = .zero, size: CGSize = CGSize(width: 100, height: 100), dragOffset: CGPoint = .zero) {
        self.noteText = noteText
        self.noteColor = noteColor
        self.textColor = textColor
        self.isBold = isBold
        self.position = position
        self.size = size
        self.dragOffset = dragOffset  // Initialize the property
    }
}

struct NoteToolbar: View {
    @Binding var notes: [NoteModel]
    @Binding var note: NoteModel?
    @State private var activeToolbarOption: ToolbarOption = .none
    @State private var showingAlert = false

    let availableColors: [Color] = [
        Color(red: 1.0, green: 0.8, blue: 0.8), // pink
        Color(red: 1.0, green: 1.0, blue: 0.6), // yellow
        Color(red: 0.96, green: 0.96, blue: 0.86), // beige
        Color(red: 0.6, green: 1.0, blue: 0.6), // mint
        Color(red: 0.53, green: 0.81, blue: 0.92) // skyBlue
    ]

    private func deleteNote() {
        if let note = note {
            notes.removeAll { $0.id == note.id }
        }
        showingAlert = false
    }

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button(action: {
                    showingAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(width: 30, height: 30)
                        .font(.system(size: 25))
                        .offset(x:10)


                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure you want to delete this note?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteNote()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Button(action: {
                    activeToolbarOption = activeToolbarOption == .textColorPicker ? .none : .textColorPicker
                }) {
                    Label("Text Color", systemImage: "textformat")
                        .frame(width: 30, height: 30)
                        .font(.system(size: 25))
                        .offset(x:30)

                }

                Spacer()

                Button(action: {
                    activeToolbarOption = activeToolbarOption == .colorPicker ? .none : .colorPicker
                }) {
                    Label("Background Color", systemImage: "paintpalette")
                        .frame(width: 30, height: 30)
                        .font(.system(size: 25))
                        .offset(x:10)

                }
                Spacer()
                Button(action: {
                    // Add user profile functionality
                }) {
                    Image(systemName: "person.circle")
                        .frame(width: 30, height: 30)
                        .font(.system(size: 25))
                        .offset(x:-20)

                }
            }
            .padding(.vertical, 25)
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 3)

            if activeToolbarOption == .colorPicker {
                colorPickerSection
            } else if activeToolbarOption == .textColorPicker {
                textColorPickerSection
            }
        }
        .padding(.bottom, 30)
}

    private var colorPickerSection: some View {
        HStack {
            ForEach(availableColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        if let note = note {
                            note.noteColor = color
                            activeToolbarOption = .none
                        }
                    }
            }
        }
        .padding()
    }

    private var textColorPickerSection: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(availableColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            if let note = note {
                                note.textColor = color
                                activeToolbarOption = .none
                            }
                        }
                }
                
                Button(action: {
                    if let note = note {
                        note.isBold.toggle()
                    }
                }) {
                    Image(systemName: "bold")
                        .frame(width: 30, height: 30)
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
}



struct NoteView: View {
    @Binding var note: NoteModel

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(note.noteColor)
                .frame(width: note.size.width, height: note.size.height)
                .offset(x: note.position.x, y: note.position.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                          //  let newLocation = CGPoint(x: note.position.x + value.translation.width,
                                  //                    y: note.position.y + value.translation.height)
                            
                            
                            let newLocation = value.location
                            
                            note.position = newLocation
                            
                            print("test111")

                        }
                        .onEnded { value in
//                            let newLocation = CGPoint(x: note.position.x + value.translation.width,
//                                                      y: note.position.y + value.translation.height)
//                            note.position = newLocation
                            
                            let newLocation = value.location
                            
                            note.position = newLocation
                            
                            print("end!!")
                        }
                )
            TextField("", text: $note.noteText)
                .foregroundColor(note.textColor)
                .font(note.isBold ? .title.bold() : .title)
                .padding()
                .frame(width: note.size.width, height: note.size.height)
                .background(Color.clear)
        }
    }
}

struct NoteToolbar_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNote = NoteModel(noteText: "Sample Note", noteColor: .blue, textColor: .white, position: CGPoint(x: 50, y: 50))

        let notes: [NoteModel] = [sampleNote]

        return NoteToolbar(notes: .constant(notes), note: .constant(sampleNote))
    }
}
