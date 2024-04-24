import SwiftUI

struct CustomMenu: View {
    @Binding var showMenu: Bool // Binding للتحكم في العرض من خارج الكومبوننت

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                withAnimation {
                    self.showMenu = false
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
    @State private var navigateToNoteView = false
    @State private var showCustomMenu = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Button(action: {
                        navigateToNoteView = true
                    }) {
                        Image("Tools") // تأكد من وجود هذه الصورة في مشروعك
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 100, height: 100)
                            .padding(.top, 60)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    
                    Button(action: {
                        showCustomMenu.toggle()
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .padding(30)
                    }
                    
                    Divider()
                    Button(action: {
                        // أفعال هذا الزر
                    }) {
                        Image("Image") // تأكد من وجود هذه الصورة في مشروعك
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 55, height: 50)
                            .padding()
                    }
                }
                .frame(width: 360, height: 90)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                // عرض الـ CustomMenu
                if showCustomMenu {
                    CustomMenu(showMenu: $showCustomMenu)
                        .transition(.move(edge: .top))
                        .offset(x: 35, y: -110) // إزاحة القائمة لظهورها بجانب الزر
                }
            }
            
            NavigationLink(destination: NoteView(), isActive: $navigateToNoteView) {
                EmptyView()
            }
        }
    }
    
    struct ToolbarView_Previews: PreviewProvider {
        static var previews: some View {
            ToolbarView()
        }
    }
}
