//
//  Quote_Widget.swift
//  Quote Widget
//
//  Created by Todd Meng on 12/23/20.
//

import WidgetKit
import SwiftUI

struct WidgetQuoteInfo: TimelineEntry {
    var date: Date
    let quote: QuoteInfo.Quote
    
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> WidgetQuoteInfo {
        let initialLoad = QuoteInfo.Quote(id: 0, content: "Have a wonderful day!", author: "the devs")
        let date = Date()
        return WidgetQuoteInfo(date: date, quote: initialLoad)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetQuoteInfo) -> Void) {
        let date = Date()
        let sampleQuote = QuoteInfo.Quote(id: 0, content: "Have a wonderful day!", author: "the devs")
        let entryData = WidgetQuoteInfo(date: date, quote: sampleQuote)
        completion(entryData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetQuoteInfo>) -> Void) {
        print("refreshing widget!")
        let refreshDate =  Calendar.current.date(byAdding: .minute, value: 10, to: Date())! //change value
        ViewModel.widgetGetQuotes { (response) in
            print("fetching quote - widget")
            var selectedQuote = response[0]
            for quote in response {
                if quote.liked {
                    selectedQuote = quote
                }
            }
            let entryData = WidgetQuoteInfo(date: Date(), quote: selectedQuote)
            let timeline = Timeline(entries: [entryData], policy: .after(refreshDate))
            completion(timeline)
        }
            
        
        
    }
}

struct WidgetEntryView: View {
    let entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Spacer()
                Text("\"\(entry.quote.content)\"")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .padding(10)
                Spacer()
            }
        case .systemMedium:
            HStack {
                Spacer()
                Text("\"\(entry.quote.content)\"")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-\(entry.quote.author)")
                    .font(.system(size: 11))
            }.padding(10)
        default:
            VStack {
                Spacer()
                Text("\"\(entry.quote.content)\"")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-\(entry.quote.author)")
                Spacer()
            }.padding(12)
        }
        
    }
}

@main
struct MyWidget: Widget {
    private let kind = "MyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
