
import SwiftUI
struct DetailsView: View {
    @Binding var showingPopover: Bool
    @State private var isAcceptingResponses = true
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .center) {
            // زر لإغلاق العرض
            Button(action: {
                self.showingPopover = false
            }) {
                Image(systemName: "x.circle")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .light))
            }
            .padding(.leading, -160)
            .padding(.top, 15)

            Text("Friends Gathering")
                .font(.body)
                .padding([.leading, .trailing, .top])
            Divider()
                .padding(.horizontal)

            HStack(alignment: .center) {
                Text("1245667727")
                    .font(.title)
                    .foregroundColor(Color("GrayMid"))
                    .padding()

                Button(action: {
                    UIPasteboard.general.string = "1245667727"
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.black)
                }
            }

            Button(action: {
                self.showingShareSheet = true
            }) {
                HStack(alignment: .center, spacing: 20) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    Text("Share")
                        .font(.body)
                        .foregroundColor(.black)
                }
                .frame(width: 120, height: 50)
                .background(Color("MainColor"))
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityView(activityItems: ["Friends Gathering: 1245667727"])
            }

            Toggle(isOn: $isAcceptingResponses) {
                Text("Accepting responses")
            }
            .padding()

            Spacer()
        }
        .frame(width: 350, height: 300)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 30)
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(showingPopover: .constant(true))
    }
}
