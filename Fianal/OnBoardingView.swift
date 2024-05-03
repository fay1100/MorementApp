//
//  OnBoardingView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 22/10/1445 AH.
//

import SwiftUI

struct OnBoardingView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MainView()) {
                    Text("Skip")
                } .navigationBarBackButtonHidden(true)
                    .padding()
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .padding()
                    .offset(x:140,y:-30)
                Image("OB1")
                    .resizable()
                Text("Focus on your moments")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("With your family and friends, and keep those memories here.")
                    .padding(.all)
                
                NavigationLink(destination: OnBoarding2()) {
                    Text("Next")
                }
                
                .foregroundColor(.white)
                .frame(width: 358 , height: 45)
                .background(Color.yellow)
                .cornerRadius(10)
                
            }
            
        }
    }
}
struct OnBoarding2: View {
        var body: some View {
            NavigationView {
                VStack {
                    NavigationLink(destination: MainView()) {
                        Text("Skip")
                    }.navigationBarBackButtonHidden(true)
                    .padding()
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .padding()
                    .offset(x:140,y:-30)
                    Image("OB4")
                        .resizable()
                    Text("Save it in one place")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("Anytime and anywhere, you and those who love to share can look back to it with AppName. ")
                        .padding(.all)
                    
                    NavigationLink(destination: MainView()) {
                        Text("Let's start")
                    }.navigationBarBackButtonHidden(true)
                            .foregroundColor(.white)
                            .frame(width: 358 , height: 45)
                            .background(Color.yellow)
                            .cornerRadius(10)
                            .padding()
                           
                }
            }
        }
    }

#Preview {
    OnBoardingView()
}
