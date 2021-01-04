//
//  ViewModel.swift
//  Quotes
//
//  Created by Todd Meng on 12/19/20.
//

import Foundation

let HerokuUrl = "https://quote-app-rest-api.herokuapp.com/"
let TestUrl = "http://127.0.0.1:5000/"
let PythonanywhereUrl = "http://toadmangopython.pythonanywhere.com/"


class ViewModel: ObservableObject {
    @Published private var model: QuoteInfo
    private let numberOfQuotes = 3
    
    static let setUpdateDateKey = "setUpdateDate"
    static let userIDKey = "userID"
    
    static let userDefaults = UserDefaults(suiteName: "group.com.toadmengo.Quotes")!
    private static let timeInterval = 86400.0
    
    init() {
        let initialLoad = QuoteInfo(quote: [QuoteInfo.Quote(id: 0, content: "Attempting to get your quotes...", author: "")], loading: true)
        model = initialLoad
        
        let userID = ViewModel.userDefaults.integer(forKey: ViewModel.userIDKey)
        print(userID)
        if userID == 0 {
            getUserID()
        } else {
            let updated = refreshQuotes(id: userID)
            if !updated {
                print("fetching from db")
                getQuotes(id: userID, newQuote: 0, firstTime: false)
            }
        }
    }

    
    private func refreshQuotes(id: Int) -> Bool {
        let now = Date()
        if let setUpdate = ViewModel.userDefaults.data(forKey: ViewModel.setUpdateDateKey) {
            if let setUpdateDate = try? JSONDecoder().decode(Date.self, from: setUpdate) {
                print(now)
                print(setUpdateDate)
                if now > setUpdateDate.addingTimeInterval(ViewModel.timeInterval + 300.0) { //ViewModel.timeInterval + 300.0
                    print(setUpdateDate)
                    getQuotes(id: id, newQuote: 1, firstTime: false)
                    return true
                }
            }
        }
        return false
    }
    
    private func getQuotes(id: Int, newQuote: Int, firstTime: Bool) {
        ViewModel.fetchQuote(id: id, newQuote: newQuote) { (json) in
            print("fetching your quotes")
            var likedIndex: Int? = nil
            if newQuote == 1 {
                let _ = ViewModel.setDefaultUpdateTime(firstTime: firstTime)
                QuoteInfo.saveToDefaults(element: likedIndex, key: "likedQuote")
            }
            else if newQuote == 0 {
                if let data = ViewModel.userDefaults.data(forKey: "likedQuote") {
                    if let index = try? JSONDecoder().decode(Int?.self, from: data) {
                        likedIndex = index
                    }
                }
            }
            var quotes: Array<QuoteInfo.Quote> = []
            for quote in json {
                let translatedQuote = QuoteInfo.Quote(id: quote.id, content: quote.content, author: quote.author, liked: false)
                quotes.append(translatedQuote)
            }
            if (likedIndex != nil) {
                quotes[likedIndex!].liked = true
            }
            
            QuoteInfo.saveToDefaults(element: quotes, key: QuoteInfo.storedQuotes)
            
            self.model = QuoteInfo(quote: quotes, loading: false)
        }
    }
    
    private static func fetchQuote(id: Int, newQuote: Int, completion: @escaping ([Response])-> ()) {

            guard let url = URL(string: PythonanywhereUrl + "UserGet/\(id)/\(newQuote)") else { // TODO!
                print("URL not found")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
        
                    print("error \(error)")
                    return
                }
                if let data = data {
                    if let json = try? JSONDecoder().decode([Response].self, from: data) {
                        print("decoding quote succesful")
                        DispatchQueue.main.async {
                            print("quote fetch sucessful")
                            completion(json)
                            return
                        }
                    }
                }
            }.resume()

    }
    
    private static func setDefaultUpdateTime(firstTime: Bool) -> Date? {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        
        let startRefreshDateString = "\(year)-\(month)-\(day) 06:00:00"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        
        guard let startRefreshDate = formatter.date(from: startRefreshDateString) else {
            print("error creating date")
            return nil}
        
        if let startRefreshJson = try? JSONEncoder().encode(startRefreshDate) {
            ViewModel.userDefaults.set(startRefreshJson, forKey: ViewModel.setUpdateDateKey)
        }
        
        if firstTime {
            if date < startRefreshDate {
                let newRefreshDate = Calendar.current.date(byAdding: .day, value: -1, to: startRefreshDate)!
                if let startRefreshJson = try? JSONEncoder().encode(newRefreshDate) {
                    print(date)
                    print(newRefreshDate)
                    ViewModel.userDefaults.set(startRefreshJson, forKey: ViewModel.setUpdateDateKey)
                    return startRefreshDate
                }
            }
        }
        print(date)
        print(startRefreshDate)
        return startRefreshDate
    }
    
    struct Response: Codable {
        var id: Int
        var content: String
        var author: String
        var likes: Int
        var religious: Bool?
        var science: Bool?
    }
    
    
    private func getUserID() {
        fetchID { (id) in
            let userDefaults = UserDefaults(suiteName: "group.com.toadmengo.Quotes")!
            userDefaults.set(id.id, forKey: ViewModel.userIDKey)
            self.getQuotes(id: id.id, newQuote: 1, firstTime: true)
        }
    }
    
    private func fetchID(completion: @escaping (UserID) -> ()) {
        
        guard let url = URL(string: PythonanywhereUrl + "UserGet/0/1") else {
            print("URL not found")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                if let json = try? JSONDecoder().decode(UserID.self, from: data) {
                    DispatchQueue.main.async {
                        completion(json)
                    }
                }
            }
        }.resume()
    }
    
    struct UserID: Codable {
        var id: Int
    }
    
    
    
    
    //MARK: - access
    var quote: QuoteInfo.Quote{
        return model.selectedQuotes[model.currentQuote]
    }
    
    
    var author: String {
        return "-" + model.selectedQuotes[model.currentQuote].author
    }
    
    var loading: Bool {
        return model.loading
    }
    
    var liked: Bool {
        model.selectedQuotes[model.currentQuote].liked
    }
    
    var currentQuote: Int {
        model.currentQuote
    }
    
    //MARK: - intents
    
    func like() {
        model.setLike()
    }
    
    
    func nextQuote() {
        model.nextQuote()
    }
    
    func prevQuote() {
        model.prevQuote()
    }
    
    
    // MARK: - widget
    
    static func widgetGetQuotes(completion: @escaping ([QuoteInfo.Quote])-> ()) {
        if let userDefaults = UserDefaults(suiteName: "group.com.toadmengo.Quotes") {
            let id = userDefaults.integer(forKey: ViewModel.userIDKey)
            let now = Date()
            if let setUpdate = userDefaults.data(forKey: ViewModel.setUpdateDateKey) {
                if let setUpdateDate = try? JSONDecoder().decode(Date.self, from: setUpdate) {
                    if now >= setUpdateDate.addingTimeInterval(ViewModel.timeInterval) {
                        let likedIndex: Int? = nil
                        QuoteInfo.saveToDefaults(element: likedIndex, key: "likedQuote")
                    
                        fetchQuote(id: id, newQuote: 1) { (json) in
                            let _ = setDefaultUpdateTime(firstTime: false)
                            var quotes: Array<QuoteInfo.Quote> = []
                            for quote in json {
                                let translatedQuote = QuoteInfo.Quote(id: quote.id, content: quote.content, author: quote.author, liked: false)
                                quotes.append(translatedQuote)
                            }
                            completion(quotes)
                            QuoteInfo.saveToDefaults(element: quotes, key: QuoteInfo.storedQuotes)
                        }
                        return
                    } else {
                        completion(QuoteInfo.returnDefaultQuotes(key: QuoteInfo.storedQuotes)!)
                        
                    }
                }
            }

        }

    }
    
}
