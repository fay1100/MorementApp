import SwiftUI
import CloudKit

// StickyNote data structure
class StickyNote: Identifiable, ObservableObject {
    let id = UUID()
    @Published var text: String
    @Published var position: CGPoint
    @Published var scale: CGFloat
    @Published var color: Color
    @Published var isBold: Bool
    @Published var rotation: Angle  // Add rotation property

    var recordID: CKRecord.ID?  // لتخزين معرف CloudKit

    // البناء المحدث
    init(text: String, position: CGPoint = CGPoint(x: 100, y: 100), scale: CGFloat = 1.0, color: Color = .yellow, isBold: Bool = false, rotation: Angle = .zero, recordID: CKRecord.ID? = nil) {
        self.text = text
        self.position = position
        self.scale = scale
        self.color = color
        self.isBold = isBold
        self.rotation = rotation
        self.recordID = recordID
    }
}

struct StickyNoteView: View {
    @ObservedObject var stickyNote: StickyNote

    var body: some View {
        VStack {
            TextField("Enter note text", text: $stickyNote.text)
                .padding()
                .frame(width: 200, height: 200)  // Set fixed size for the sticky note
                .background(stickyNote.color)
                .cornerRadius(15)  // Add corner radius
                .scaleEffect(stickyNote.scale)
                .position(stickyNote.position)
                .multilineTextAlignment(.center)  // Center text alignment
                .foregroundColor(.black)  // Text color
                .font(stickyNote.isBold ? .system(size: 16, weight: .bold) : .system(size: 16, weight: .regular))
                .rotationEffect(stickyNote.rotation)  // Apply rotation
        }
    }
}

struct StickyNoteToolbar: View {
    @ObservedObject var stickyNote: StickyNote
    var onDelete: () -> Void
    var onBold: () -> Void
    @State private var showColors = false

    let availableColors: [Color] = [
        Color.purple, Color.yellow, Color.orange, Color.green, Color.blue
    ]

    var body: some View {
        ZStack {
            HStack {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(.trailing, 20)
                }

                Divider()

                Button(action: onBold) {
                    Image(systemName: "bold")
                        .foregroundColor(.black)
                        .padding(.leading, 40)
                }

                Divider()

                Button(action: {
                    showColors.toggle()
                }) {
                    Image(systemName: "paintpalette")
                        .foregroundColor(.black)
                        .padding(.leading, 70)
                }
            }
            .frame(width: 360, height: 90)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))

            if showColors {
                colorPickerSection
            }
        }
    }

    private var colorPickerSection: some View {
        VStack {
            HStack {
                ForEach(availableColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            stickyNote.color = color
                            showColors = false
                        }
                }
                .padding(15)
            }
            .frame(width: 360, height: 90)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .cornerRadius(10)
        }
    }
}

struct StickyNoteToolbar_Previews: PreviewProvider {
    @StateObject static var sampleNote = StickyNote(text: "Sample Note")
    
    static var previews: some View {
        VStack {
            StickyNoteToolbar(
                stickyNote: sampleNote,
                onDelete: {},
                onBold: {}
            )
            .background(Color.gray.opacity(0.1))
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}

