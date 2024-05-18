import SwiftUI


struct Sticker: Identifiable {
    var id = UUID()
    var imageName: String
    var position: CGPoint = .zero  // قيمة افتراضية للموقف
    var size: CGSize = CGSize(width: 100, height: 100)  // قيمة افتراضية للحجم
    var dragOffset: CGSize = .zero  // تستخدم لتتبع حركة الاستكر
}



struct StickerViewWithGesture: View {
    @Binding var note: NoteModel

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(note.noteColor)
                .frame(width: 150, height: 150)
                .offset(x: note.position.x, y: note.position.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Temporarily update the position during drag
                            let newLocation = CGPoint(x: note.position.x + value.translation.width,
                                                      y: note.position.y + value.translation.height)
                            note.position = newLocation
                        }
                        .onEnded { value in
                            // Permanently update the position when the drag ends
                            let newLocation = CGPoint(x: note.position.x + value.translation.width,
                                                      y: note.position.y + value.translation.height)
                            note.position = newLocation
                        }
                )
            TextField("", text: $note.noteText)
                .foregroundColor(note.textColor)
                .font(.title)
                .padding()
                .frame(width: 150, height: 150)
                .background(Color.clear)
        }
    }
}

struct StickerBoard: View {
        @Binding var navigateToBoardView: Bool
        @Binding var droppedStickers: [Sticker]
        @Binding var inputImage: UIImage?
        let stickers: [Sticker] = [
            Sticker(imageName: "butterfly"),  // يجب أن يكون متوفراً في Assets.xcassets أو كأيقونة نظام
            Sticker(imageName: "cake"),       // مثل الأول
        ]

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 32) {
                        ForEach(stickers) { sticker in
                            Button(action: {
                                droppedStickers.append(sticker)
                                navigateToBoardView = true
                            }) {
                                // تأكد من استخدام الصور المناسبة حسب النوع
                                if UIImage(named: sticker.imageName) != nil {
                                    Image(sticker.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .padding(.vertical, 10)
                                } else {
                                    Image(systemName: sticker.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Stickers")
            }
        }
    }
    struct StickerBoard_Previews: PreviewProvider {
        static var previews: some View {
            let droppedStickers = [
                Sticker(imageName: "star", position: CGPoint(x: 10, y: 10)),  // إضافة مثال للاستكر مع موقف معين
                Sticker(imageName: "butterfly", position: CGPoint(x: 50, y: 50))  // مثال آخر
            ]

            // توفير ربط مؤقت لـ inputImage والربط المباشر للمتغيرات الأخرى
            StickerBoard(
                navigateToBoardView: .constant(false),
                droppedStickers: .constant(droppedStickers),
                inputImage: .constant(nil)
            )
        }
    }

//struct StickerBoard_Previews: PreviewProvider {
//    static var previews: some View {
//        let droppedStickers = [
//            Sticker(imageName: "star", position: CGPoint(x: 10, y: 10)),  // إضافة مثال للاستكر مع موقف معين
//            Sticker(imageName: "butterfly", position: CGPoint(x: 50, y: 50))  // مثال آخر
//        ]
//        
//        // توفير ربط مؤقت لـ inputImage والربط المباشر للمتغيرات الأخرى
//        StickerBoard(
//            navigateToBoardView: .constant(false),
//            droppedStickers: .constant(droppedStickers),
//            inputImage: .constant(nil)
//        )
//    }
//}
