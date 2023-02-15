//
//  ContentView.swift
//  ChatGPTwithSpeech
//
//  Created by 林 政樹 on 2023/02/13.
//

import SwiftUI

struct ContentView<ViewModel: ViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var canTouchDown = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(viewModel.models, id: \.self) {data in
                                let color: UIColor = data.isMe ? UIColor.lightGray : UIColor.white
                                let side: CGFloat = data.isMe ? 30 : 0
                                Text(data.text)
                                    .foregroundColor(.init(uiColor: color))
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.init(top: 20, leading: side, bottom: 10, trailing: side))
                            }
                            Color.clear.padding(.bottom, 60).id(200)
                        }
                        .onChange(of: viewModel.models) { _ in
                            withAnimation {
                                proxy.scrollTo(200)
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            let buttonSize:CGFloat = canTouchDown ? 60 : 56
                            Image(systemName: "mic")
                                .foregroundColor(.black)
                                .font(.system(size: 24))
                                .frame(width: buttonSize, height: buttonSize, alignment: .center)
                                .background(Color(UIColor.systemGroupedBackground))
                                .cornerRadius(buttonSize*0.5)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if canTouchDown == true {
                                                viewModel.askChatGPT()
                                            }
                                            canTouchDown = false
                                        }
                                        .onEnded { value in
                                            if canTouchDown == false {
                                                viewModel.endChatGPT()
                                            }
                                            canTouchDown = true
                                        }
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.init(top: geometry.safeAreaInsets.top + 10, leading: 20, bottom: geometry.safeAreaInsets.bottom + 10, trailing: 20))
            }
            .edgesIgnoringSafeArea(.all)
            
            if viewModel.isAsking {
                withAnimation {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ActivityIndicator()
                    }
                }
            }
        }
        .background(Color.init(uiColor: .black))
        .onAppear{
            viewModel.setup()
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
