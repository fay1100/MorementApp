import SwiftUI
import CloudKit

struct StickerGridView: View {
    var selectSticker: (Sticker) -> Void
    @Binding var showStickers: Bool

    let stickers: [String] = [
        "Stiker1", "Stiker2", "Stiker3", "Stiker4", "Stiker5", "Stiker6",
        "Stiker7", "Stiker8", "Stiker9","Stiker10", "Stiker12", "Stiker13", "Stiker14","Stiker15","Stiker16", "Stiker17","Stiker18","Stiker19","Stiker20","Stiker21","Stiker22","Stiker23","Stiker24","Stiker25","Stiker26","Stiker27","Stiker28","Stiker29","Stiker30","Stiker31","Stiker32","Stiker33","Stiker34","Stiker35",
    ]

    var body: some View {
        ZStack{

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ForEach(stickers, id: \.self) { sticker in
                        Image(sticker)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 120) // Adjust the size as needed
                            .onTapGesture {
                                if let image = UIImage(named: sticker) {
                                    let newSticker = Sticker(image: image)
                                    self.selectSticker(newSticker)
                                    self.showStickers = false
                                }
                            }
                    }
                }
                .padding()
            }.background(Color.white)
            .navigationTitle("Stickers")
        }
    }
}



struct StickerGridView_Previews: PreviewProvider {
    @State static var showStickers = true
    
    static var previews: some View {
        StickerGridView(selectSticker: { _ in }, showStickers: $showStickers)
    }
}







struct Sticker: Identifiable {
    var id = UUID()
    var image: UIImage
    var position: CGPoint = CGPoint(x: 100, y: 100)  // Default position
    var scale: CGFloat = 1.0  // Default scale
    var isFromCameraRoll: Bool = false  // Indicates if the sticker is from the camera roll
    var recordID: CKRecord.ID? = nil  // Add recordID for CloudKit
}





