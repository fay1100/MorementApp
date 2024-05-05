import SwiftUI

enum ToolbarOption {
    case none
    case colorPicker
    case textColorPicker
    case alignmentOptions
}

class NoteModel: ObservableObject {
    @Published var noteText: String = ""
    @Published var noteColor: Color = Color("skyBlue")
    @Published var textColor: Color = .black
    @Published var textAlignment: TextAlignment = .leading
}

struct NoteView: View {
    @StateObject private var noteModel = NoteModel()
    @State private var activeToolbarOption: ToolbarOption = .none
    @State private var isToggleOn = false
    @State private var selectedNoteIndex: Int?

    let availableColors: [Color] = [
        Color(red: 1.0, green: 0.8, blue: 0.8), // pink
        Color(red: 1.0, green: 1.0, blue: 0.6), // yellow
        Color(red: 0.96, green: 0.96, blue: 0.86), // beige
        Color(red: 0.6, green: 1.0, blue: 0.6), // mint
        Color(red: 0.53, green: 0.81, blue: 0.92), // skyBlue
    ]

    var body: some View {
        NavigationView {
            VStack {
                Divider()

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(noteModel.noteColor)
                        .frame(width: 350, height: 490)
                        .overlay(
                            VStack(spacing: 20) {
                                TextField("Enter text here...", text: $noteModel.noteText)
                                    .padding(.top)
                                    .padding(.leading, 10)
                                    .font(.title)
                                    .foregroundColor(noteModel.textColor)
                                    .multilineTextAlignment(noteModel.textAlignment)
                                Spacer()

                                HStack {
                                    Text("From: Deemh")
                                    Spacer()
                                    Toggle("", isOn: $isToggleOn)
                                        .labelsHidden()
                                }
                                .padding(.top,300)
                                .padding(.all)

                                Spacer()
                            }
                        )
                }
                .padding(.top, 10)

                HStack(spacing: 60) {
                    ToolbarIcon(iconName: "note", label: "Note color") {
                        activeToolbarOption = activeToolbarOption == .colorPicker ? .none : .colorPicker
                    }
                    ToolbarIcon(iconName: "textformat", label: "Font color") {
                        activeToolbarOption = activeToolbarOption == .textColorPicker ? .none : .textColorPicker
                    }
                    ToolbarIcon(iconName: "text.justify", label: "Alignment") {
                        activeToolbarOption = activeToolbarOption == .alignmentOptions ? .none : .alignmentOptions
                    }
                }
                .padding()

                Group {
                    Group {
                        if activeToolbarOption == .colorPicker {
                            HStack {
                                ForEach(availableColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .padding(5)
                                        .onTapGesture {
                                            noteModel.noteColor = color
                                            activeToolbarOption = .none
                                        }
                                }
                            }
                        } else {
                            HStack {
                                ForEach(availableColors.indices, id: \.self) { _ in
                                    Circle()
                                        .frame(width: 44, height: 44)
                                        .hidden()
                                }
                            }
                        }
                    }
                    .animation(.default, value: activeToolbarOption)

                    Group {
                        if activeToolbarOption == .textColorPicker {
                            ColorPicker("", selection: $noteModel.textColor)
                        } else {
                            ColorPicker("", selection: $noteModel.textColor).hidden()
                        }
                    }
                    .padding(.trailing, 180)
                    .animation(.default, value: activeToolbarOption)

                    Group {
                        if activeToolbarOption == .alignmentOptions {
                            HStack(spacing: 90) {
                                Button(action: { noteModel.textAlignment = .leading; activeToolbarOption = .none }) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 25))
                                        .foregroundColor(noteModel.textAlignment == .leading ? .black : .gray)
                                }
                                Button(action: { noteModel.textAlignment = .center; activeToolbarOption = .none }) {
                                    Image(systemName: "text.aligncenter")
                                        .font(.system(size: 25))
                                        .foregroundColor(noteModel.textAlignment == .center ? .black : .gray)
                                }
                                Button(action: { noteModel.textAlignment = .trailing; activeToolbarOption = .none }) {
                                    Image(systemName: "text.alignright")
                                        .font(.system(size: 25))
                                        .foregroundColor(noteModel.textAlignment == .trailing ? .black : .gray)
                                }
                            }
                        } else {
                            HStack(spacing: 40) {
                                ForEach(["left", "center", "right"], id: \.self) { _ in
                                    Image(systemName: "text.alignleft") // Placeholder
                                        .font(.system(size: 25))
                                        .hidden()
                                }
                            }
                        }
                    }
                    .animation(.default, value: activeToolbarOption)
                }
                .padding(.bottom, -150)

                Spacer()
            }
            .navigationBarItems(
                leading: Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("MainColor"))
                },
                trailing: NavigationLink(destination: BoardView(noteModel: noteModel)) {
                    Text("Post")
                        .foregroundColor(Color("MainColor"))
                }
            )
        }
    }
}

struct ToolbarIcon: View {
    let iconName: String
    let label: String
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: 25))
                    .foregroundColor(.yellow)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SavedNotesView: View {
    let noteModel: NoteModel
    @Binding var selectedNoteIndex: Int?
    @State private var isSelected = false

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(noteModel.noteColor)
                    .frame(width: isSelected ? 180 : 140, height: isSelected ? 180 : 140)
                    .onTapGesture {
                        withAnimation {
                            isSelected.toggle()
                        }
                    }
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isSelected ? 5 : 0)) // تحديد الزاوية الميل بالدرجات
                    .overlay(
                        VStack(spacing: 20) {
                            Text(noteModel.noteText)
                                .font(.title)
                                .foregroundColor(noteModel.textColor)
                                .multilineTextAlignment(noteModel.textAlignment == .leading ? .leading : noteModel.textAlignment == .center ? .center : .trailing)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: noteModel.textAlignment == .leading ? .leading : noteModel.textAlignment == .center ? .center : .trailing)
                            Spacer()
                        }
                    )
            }
        }
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView()
    }
}
