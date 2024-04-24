import SwiftUI

enum ToolbarOption {
    case none
    case colorPicker
    case textColorPicker
    case alignmentOptions
}

struct NoteView: View {
    @State private var noteText: String = ""
    @State private var noteColor: Color = Color("skyBlue")
    @State private var textColor: Color = .black
    @State private var textAlignment: TextAlignment = .leading
    @State private var activeToolbarOption: ToolbarOption = .none
    @State private var isToggleOn = false
    @Environment(\.dismiss) var dismiss

    let availableColors: [Color] = [
        Color("pink"), // pink
        Color("yellow2"), // yellow
        Color("lightOrang"), // beige
        Color("mint"), // mint
        Color("skyBlue") // skyBlue
    ]

    var body: some View {
        NavigationStack {
                VStack {
                    Divider()

                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(noteColor)
                            .frame(width: 350, height: 490)
                            .overlay(
                                VStack(spacing: 20) {
                                    TextField("Enter text here...", text: $noteText)
                                        .padding(.top)
                                        .padding(.leading, 10)
                                        .font(.title)
                                        .foregroundColor(textColor)
                                        .multilineTextAlignment(textAlignment)
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
                        // قروب للخيارات المرتبطة بألوان الأدوات
                        Group {
                            if activeToolbarOption == .colorPicker {
                                HStack {
                                    ForEach(availableColors, id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 44, height: 44)
                                            .padding(5)
                                            .onTapGesture {
                                                noteColor = color
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
                        
                        // قروب للخيارات المرتبطة باختيار لون النص
                        Group {
                            if activeToolbarOption == .textColorPicker {
                                ColorPicker("", selection: $textColor)
                            } else {
                                ColorPicker("", selection: $textColor).hidden()
                            }
                        }
                        .padding(.trailing, 180)
                        .animation(.default, value: activeToolbarOption)
                        
                        // قروب للخيارات المرتبطة بمحاذاة النص
                        Group {
                            if activeToolbarOption == .alignmentOptions {
                                HStack(spacing: 90) {
                                    Button(action: { textAlignment = .leading; activeToolbarOption = .none }) {
                                        Image(systemName: "text.alignleft")
                                            .font(.system(size: 25))
                                            .foregroundColor(textAlignment == .leading ? .black : .gray)
                                    }
                                    Button(action: { textAlignment = .center; activeToolbarOption = .none }) {
                                        Image(systemName: "text.aligncenter")
                                            .font(.system(size: 25))
                                            .foregroundColor(textAlignment == .center ? .black : .gray)
                                    }
                                    Button(action: { textAlignment = .trailing; activeToolbarOption = .none }) {
                                        Image(systemName: "text.alignright")
                                            .font(.system(size: 25))
                                            .foregroundColor(textAlignment == .trailing ? .black : .gray)
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
                    .padding(.bottom, -150) // تحريك القروب الكامل لأعلى
                    
                    Spacer()
                }
                .navigationBarItems(
                    leading: Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("MainColor"))
                    },
                    trailing: Button(action: {}) {
                        Text("Post")
                            .foregroundColor(Color("MainColor"))
                    }
                )
                .navigationBarBackButtonHidden(true)

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

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView()
    }
}
