
import SwiftUI

struct DetailsView: View {
    @Binding var showingPopover: Bool
    @State private var isAcceptingResponses = true
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Friends Gathering")
                .padding(.top)
            
            Divider()
                .padding(.horizontal)

            HStack(alignment: .center) {
                Text("1245667727")
                    .foregroundColor(Color.gray)
                    .padding()

                Button(action: {
                    UIPasteboard.general.string = "1245667727"
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.black)
                }
            }

            HStack {
                Button(action: {
                    self.showingPopover = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .frame(width: 115, height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("MainColor"), lineWidth: 1)
                        )
                }

                Button(action: {
                    self.showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .light))
                        Text("Share")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                    .frame(width: 115, height: 50)
                    .background(Color("MainColor"))
                    .cornerRadius(10)
                }

            }

            Toggle(isOn: $isAcceptingResponses) {
                Text("Accepting responses")
            }
            .padding()

            Spacer()
        }
        .frame(width: 270, height: 240)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 20)
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: ["Friends Gathering: 1245667727"])
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(showingPopover: .constant(true))
    }
}
