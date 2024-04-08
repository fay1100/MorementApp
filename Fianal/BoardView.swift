
import SwiftUI

struct BoardView: View {
    @State private var showingPopover = false
    var body: some View {
        NavigationView {
            ZStack {
                Image("Empty")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                
                VStack {
                    
                    HStack(spacing: 20) {
                                        Button(action: {
                                        }) {
                                            Image(systemName: "star.bubble")
                                                .foregroundColor(Color("MainColor"))
                                                .font(.system(size: 48))
                                        }
                
                                        Button(action: {
                                        }) {
                                            Text("Add your feelings")
                                                .foregroundColor(.black)
                                                .frame(width: 260, height: 50)
                                                .background(Color("MainColor"))
                                                .cornerRadius(10)
                                        }
                                    }
                                .padding(.horizontal)
                              .offset(y: 320)
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


