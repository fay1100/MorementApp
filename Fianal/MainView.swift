//
//  MainView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 11/10/1445 AH.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack  {
            VStack {
                Image("Empty")
                HStack(spacing: 10) {
                    Text("Start designing your boards by creating a new board")
                        .foregroundColor(Color("GrayMid"))
                        .multilineTextAlignment(.center)
//هنا عندي سوال
                    Image(systemName: "rectangle.badge.plus")
                        .foregroundColor(Color("MainColor"))

                }.padding(.horizontal)
                
            }
            .navigationBarTitle("Board")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        // Action for the first trailing button
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                Button(action: {
                    // Navigate to CreateBoardView when this button is tapped
                    // Here, you add the navigation logic
                    // For example, you can push the CreateBoardView onto the navigation stack
                }) {
                    NavigationLink(destination: CreateBoardView()) {
                        Image(systemName: "rectangle.badge.plus")
                    }
                }
            }
            )
            .accentColor(Color("MainColor"))

        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
