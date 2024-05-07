//
//  OnBoardingView.swift
//  Fianal
//
//  Created by Deemh Albaqami on 22/10/1445 AH.
//

import SwiftUI

struct OnboardingView: View {
    var onboardingData: [OnboardingItem] = [
        OnboardingItem(imageName: "OB1", title: "Focus on your moments", description: "With your family and friends, and keep those memories here."),
        OnboardingItem(imageName: "OB2", title: "Save it in one place", description: "Anytime and anywhere, you and those who love to share can look back to it with MoreMent."),
        OnboardingItem(imageName: "OB3", title: "Enter your name", description: "Choose a Good one, you can’t change it!")
    ]

    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @State private var userName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(onboardingData.indices, id: \.self) { index in
                        OnboardingSlideView(item: onboardingData[index], isLastSlide: index == onboardingData.indices.last, userName: $userName)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .padding()

                PageControl(numberOfPages: onboardingData.count, currentPage: $currentPage)
                    .padding()

                Button(action: {
                    if currentPage < onboardingData.count - 1 {
                        currentPage += 1
                    } else {
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage == onboardingData.count - 1 ? "Let's Start" : "Next")
                        .frame(width: 358, height: 46)
                        .background(Color("MainColor"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .navigationBarItems(trailing: currentPage == onboardingData.indices.last ? nil : Button("Skip") {
                currentPage = onboardingData.indices.last ?? currentPage
            }
            .foregroundColor(.gray))
            .fullScreenCover(isPresented: $isOnboardingComplete, content: {
                MainView().environmentObject(BoardViewModel())
            })
        }
    }
}

struct OnboardingSlideView: View {
    let item: OnboardingItem
    let isLastSlide: Bool
    @Binding var userName: String

    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()

            Text(item.title)
                .font(.title)
                .padding()

            if isLastSlide {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text(item.description)
                .multilineTextAlignment(.center)
        }.padding()
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(currentPage == index ? Color("MainColor") : .gray)  
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}





//import SwiftUI
//
//struct OnBoardingView: View {
//    var body: some View {
//        NavigationView {
//            VStack {
//                NavigationLink(destination: MainView()) {
//                    Text("Skip")
//                } .navigationBarBackButtonHidden(true)
//                    .padding()
//                    .foregroundColor(.gray)
//                    .cornerRadius(10)
//                    .padding()
//                    .offset(x:140,y:-30)
//                Image("OB1")
//                    .resizable()
//                Text("Focus on your moments")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.top)
//                Text("With your family and friends, and keep those memories here.")
//                    .padding(.all)
//
//                NavigationLink(destination: OnBoarding2()) {
//                    Text("Next")
//                }
//
//                .foregroundColor(.white)
//                .frame(width: 358 , height: 45)
//                .background(Color.yellow)
//                .cornerRadius(10)
//
//            }
//
//        }
//    }
//}
//struct OnBoarding2: View {
//        var body: some View {
//            NavigationView {
//                VStack {
//                    NavigationLink(destination: MainView()) {
//                        Text("Skip")
//                    }.navigationBarBackButtonHidden(true)
//                    .padding()
//                    .foregroundColor(.gray)
//                    .cornerRadius(10)
//                    .padding()
//                    .offset(x:140,y:-30)
//                    Image("OB2")
//                        .resizable()
//                    Text("Save it in one place")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .padding(.top)
//                    Text("Anytime and anywhere, you and those who love to share can look back to it with AppName. ")
//                        .padding(.all)
//
//                    NavigationLink(destination: MainView()) {
//                        Text("Let's start")
//                    }.navigationBarBackButtonHidden(true)
//                            .foregroundColor(.white)
//                            .frame(width: 358 , height: 45)
//                            .background(Color.yellow)
//                            .cornerRadius(10)
//                            .padding()
//
//                }
//            }
//        }
//    }
//
//#Preview {
//    OnBoardingView()
//}
