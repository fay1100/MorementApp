//
//  JoinView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 29/10/1445 AH.
//

import SwiftUI

struct JoinView: View {
    @Binding var showingPopover: Bool
    @State private var codeNum = ""
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Enter the board code")
                .padding(.top)
            
            Divider()
                .padding(.horizontal)
            
            TextField("Enter the board code", text: $codeNum)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    self.showingPopover = false
                }) {
                    VStack {
                        Text("Cancel")
                            .foregroundColor(.black)
                    }
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
                    VStack {
                        Text("Join")
                            .foregroundColor(.black)
                    }
                    .frame(width: 115, height: 50)
                    .background(Color("MainColor"))
                    .cornerRadius(8)
                }
                

            } .padding(.bottom)
            
        }
        .frame(width: 270, height: 240)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 20)
    }
}

struct JoinView_Previews: PreviewProvider {
    static var previews: some View {
        JoinView(showingPopover: .constant(true))
    }
}
