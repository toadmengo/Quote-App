//
//  ContentView.swift
//  Quotes
//
//  Created by Todd Meng on 12/19/20.
//

import SwiftUI

let cardMargin:CGFloat = 60

struct ContentView: View {

    @ObservedObject var viewVM: ViewModel
    @State var showCard = true
    @State var swipeRight = true
    
    var body: some View {
        GeometryReader(content: { geometry in
            
            VStack {
                Rectangle()
                    .frame(height: geometry.size.height * 0.05, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .opacity(0)
                if showCard {
                QuoteCard(viewVM: viewVM)
                    .transition(.move(edge: (swipeRight ? .trailing : .leading)))
                    .animation(.easeIn)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onEnded({ value in
                                    if value.translation.width < -geometry.size.width/5 {
                                        withAnimation(.linear(duration: 0.5)) {
                                            showCard = false
                                            swipeRight = false
                                        }
                                        viewVM.nextQuote()
                                        withAnimation(.linear(duration: 0.5)) {
                                            showCard = true
                                        }
                                    }
                                    else if value.translation.width > geometry.size.width/5 {
                                        withAnimation(.linear(duration: 0.5)) {
                                            showCard = false
                                            swipeRight = true
                                        
                                        }
                                        viewVM.prevQuote()
                                        withAnimation(.linear(duration: 0.5)) {
                                            showCard = true
                                        }
                                        
                                    }
                                }))
                } else {
                    QuoteCard(viewVM: viewVM)
                        .transition(.move(edge: (!swipeRight ? .trailing : .leading)))
                        .animation(.easeIn)
                }
                
                InteractionView(vm: viewVM)
            }
        })

    }
    
}


struct QuoteCard: View {
    @ObservedObject var viewVM: ViewModel
    
    var body: some View {
        GeometryReader(content: { geometry in
            Group {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color.black, lineWidth: 3)
                        .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(viewVM.currentQuote == 0 ? Color.gray : (viewVM.currentQuote == 1 ? Color.red : Color.purple))
                                        .opacity(0.2))

                    VStack {
                        Text("\"\(viewVM.quote.content)\"")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(cardMargin/2 + 10)
                            .position(x: (geometry.size.width-cardMargin)/2, y: geometry.size.height * 0.35)
                        Spacer()
                        HStack {
                            Text("\(viewVM.quote.author)")
                                .font(.footnote)
                                .padding(15)
                        }
                    }
                }
            }
            .position(x: geometry.size.width/2, y: geometry.size.height * 0.4)
            .frame(width: geometry.size.width - cardMargin, height: geometry.size.height - cardMargin, alignment: .center)
        })
    }
}

struct InteractionView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .opacity(0)
            VStack {
                HStack {
                    GeometryReader(content: { geometry in
                        LikeButton(vm: vm)
                            .position(x: geometry.size.width/2, y: geometry.size.height/2)
                            .font(.system(size: geometry.size.width/5))
                            .onTapGesture {
                                vm.like()
                            }
                    })
                    
                }
            }.opacity(vm.loading ? 0 : 1) //Animation needed
        }
    }
}

struct LikeButton: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .opacity(vm.liked ? 1 : 0)
                .scaleEffect(vm.liked ? 1.0: 0.2)
                .animation(.linear)
            Image(systemName: "heart")
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let quotePreview = ViewModel()
        ContentView(viewVM: quotePreview)
    }
}
