//
//  QuoteModel.swift
//  Quotes
//
//  Created by Todd Meng on 12/19/20.
//

import Foundation

struct QuoteInfo {
    private(set) var loading: Bool = true
    private(set) var selectedQuotes: Array<Quote>
    private(set) var currentQuote: Int = 0
    private let numberOfQuotes = 3

    
    init(quote: Array<Quote>, loading: Bool) {
        selectedQuotes = quote
        self.loading = loading
        for index in 0..<selectedQuotes.count {
            if selectedQuotes[index].liked {
                self.currentQuote = index
            }
        }
    }

    
    struct Quote: Identifiable, Codable {
        var id: Int
        var content: String
        var author: String
        var liked: Bool = false
    }
    
    private func sendLike() {
        let url = URL(string: PythonanywhereUrl + "quotes/\(self.selectedQuotes[currentQuote].id)/update")
        var likeInt: Int
        
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if self.selectedQuotes[currentQuote].liked {
            likeInt = 1
        } else {
            likeInt = -1
        }
        struct jsonInfo: Codable {
            let likes: Int
        }
        let json = jsonInfo(likes: likeInt)
        
        let encoder = JSONEncoder()
        
        if let jsonData = try? encoder.encode(json) {
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { (data, response, error) in
            }.resume()
        }
    }
    
    mutating func setLike() {
        for i in 0..<selectedQuotes.count {
            if i != currentQuote {
                selectedQuotes[i].liked = false
            }
        }
        selectedQuotes[currentQuote].liked = !selectedQuotes[currentQuote].liked
        if selectedQuotes[currentQuote].liked {
            QuoteInfo.saveToDefaults(element: currentQuote, key: "likedQuote")
            print("stored like")
        }
        sendLike()
        QuoteInfo.saveToDefaults(element: selectedQuotes, key: QuoteInfo.storedQuotes)
    }
    
    mutating func nextQuote() {
        self.currentQuote = (self.currentQuote < selectedQuotes.count - 1 ? self.currentQuote + 1: 0)
    }
    
    mutating func prevQuote() {
        self.currentQuote = (self.currentQuote == 0 ? selectedQuotes.count-1 : self.currentQuote - 1)
    }
    
    
    // MARK: - userdefaults
    
    static let storedQuotes = "storedQuotes"
    
    private static let userDefault = UserDefaults(suiteName: "group.com.toadmengo.Quotes")!
    
    static func saveToDefaults<thing: Encodable>(element: thing, key: String){
        if let jsonData = try? JSONEncoder().encode(element) {
            userDefault.setValue(jsonData, forKey: key)
        } else {
            print("error encoding")
        }
    }
    
    static func returnDefaultQuotes (key: String)-> [Quote]?{
        if let obtainDataKey = userDefault.data(forKey: storedQuotes) {
            if let storedQuotes = try? JSONDecoder().decode([Quote].self, from: obtainDataKey) {
                return storedQuotes
            }
            else {
                print("error decoding")
                return nil
            }
        } else {
        return nil
        }
    }
    
}
