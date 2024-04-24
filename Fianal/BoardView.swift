import  SwiftUI

struct BoardView: View {
    @State private var showingPopover = false
    var body: some View {
        NavigationStack{
            ZStack {
                Color("GrayLight") // تعيين اللون الخلفي للـ BoardView
                    .ignoresSafeArea()
                Image("Empty")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Divider()
                    .padding(.bottom, 700)

                VStack {
                    ToolbarView()
                        .padding(.top , 550)
                }
            }
            .navigationBarTitle("My Friends' Gathering", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {

                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("MainColor"))
                },
                trailing: Button(action: {
                    self.showingPopover = true
                }) {
                    Text("Details")
                        .foregroundColor(Color("MainColor"))
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
                        .animation(.easeOut(duration: 0.2))
                }
            }, alignment: .center
        )
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}


  
