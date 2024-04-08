//
//  DetailsView.swift
//  Fianal
//
//  Created by Faizah Almalki on 29/09/1445 AH.
//
import SwiftUI

struct DetailsView: View {
    var body: some View {
        // Design the popover here
        VStack {
            Text("Details of the gathering")
                .font(.headline) // Change the font to a headline style
                .padding() // Add padding around the text
            // Add more UI components as needed
        }
        .frame(width: 300, height: 200) // Set the size of the popover
        .background(Color.white) // Set the background color of the popover
        .cornerRadius(10) // Make the corners of the popover rounded
        .shadow(radius: 5) // Add shadow to the popover
    }
}

#Preview {
    DetailsView()
}
