
import SwiftUI

struct CustomMenu: View {
    @Binding var showMenu: Bool
      var addNoteAction: () -> Void

    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                withAnimation {
                    self.showMenu = false
                    addNoteAction()  // استدعاء الدالة عند النقر
                }
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Take Photo")
                }
                .foregroundColor(Color("MainColor")) // تحقق من تعريف هذا اللون في ملف الأصول
            }

            Divider()

            Button(action: {
                withAnimation {
                    self.showMenu = false
                }
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Photo Library")
                }
                .foregroundColor(Color("MainColor")) // تحقق من تعريف هذا اللون في ملف الأصول
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 150, height: 100)
        .transition(.scale.combined(with: .opacity))
    }
}


struct ToolbarView: View {
    var addNoteAction: () -> Void
    @Binding var showCustomMenu: Bool
    @Binding var navigateToStickersView: Bool
    @Binding var droppedStickers: [Sticker]

    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Button(action: addNoteAction) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .padding(30)
                    }
                    Divider()
                    Button(action: { showCustomMenu.toggle() }) {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .padding(30)
                    }
                    Divider()
                    NavigationLink(destination: StickerBoard(navigateToBoardView: $navigateToStickersView, droppedStickers: $droppedStickers), isActive: $navigateToStickersView) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .padding(30)
                    }
                }
                .frame(width: 360, height: 90)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                if showCustomMenu {
                    CustomMenu(showMenu: $showCustomMenu, addNoteAction: addNoteAction)
                        .transition(.move(edge: .top))
                        .offset(x: 35, y: -110)
                }
            }
        }
        .padding(.bottom, 30)
    }
}
struct ToolbarView_Previews: PreviewProvider {
    @State static var showCustomMenu = false
    @State static var navigateToStickersView = false
    @State static var droppedStickers = [Sticker()]

    static var previews: some View {
        ToolbarView(addNoteAction: {}, showCustomMenu: $showCustomMenu, navigateToStickersView: $navigateToStickersView, droppedStickers: $droppedStickers)
    }
} 
