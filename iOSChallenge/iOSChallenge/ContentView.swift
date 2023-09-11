//
//  ContentView.swift
//  iOSChallenge
//
//  Created by HackIllinois on 9/6/23.
//

//import SwiftUI
//
//// Create the event struct
//struct MyEvent: Codable, Identifiable {
//    let id: String
//    let name: String
//    let description: String
//    let startTime: Int64
//    let endTime: Int64
//}
//
//struct MyEvents: Codable {
//    var events : [MyEvent]
//}
//// Make your API call to the HackIllinois API event endpoint
//// For help getting started, google "how to make an API call with Swift"
//
////from ChatGPT
//func fetchDataFromAPI(completion:@escaping (MyEvents) -> ()) {
//    if let url = URL(string: "https://adonix.hackillinois.org/event/") {
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                do {
//                    let decoder = JSONDecoder()
//                    var events = try decoder.decode(MyEvents.self, from: data)
//
//                    // from https://stackoverflow.com/questions/26719744/swift-sort-array-of-objects-alphabetically
//                    events.events.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
//                    events.events.sort { $0.startTime < $1.startTime }
//
//                    DispatchQueue.main.async {
//                        completion(events)
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            } else if let error = error {
//                print("Error fetching data: \(error)")
//            }
//        }.resume()
//    }
//}
//
//
//struct ContentView: View {
//    @State var events: [MyEvent] = []
//
//    var body: some View {
//        VStack {
//            Text("SCHEDULE")
//                .font(.custom("Helvetica Neue", size: 50, relativeTo: .body))
//                .fontWeight(.heavy)
//                .italic()
//                .underline()
//                .foregroundColor(.blue)
//                .padding(9)
//            if events.isEmpty {
//                Text("Loading...")
//            } else {
//                List(events) { event in
//                    VStack {
//                        TimeOfEvent(integer: event.startTime)
//                        NameOfEvent(text: event.name)
//                        DescriptionOfEvent(text: event.description)
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//                }
//            }
//        }
//        .padding()
//        /* from https://medium.com/swift-productions/fetch-json-data-display-list-swiftui-2-0-d301f401c223 */
//        .onAppear {
//            fetchDataFromAPI { myEvents in
//                self.events = myEvents.events
//            }
//        }
//    }
//}
//
//
//
//
//struct NameOfEvent: View {
//    let text: String
//
//    var body: some View {
//        Text(text)
//            .bold().foregroundColor(Color.init(UIColor.darkGray))
//            .font(.system(size: 25))
//            .frame(maxWidth: .infinity, alignment: .center)
//            .multilineTextAlignment(.center)
//            .padding(6)
//    }
//}
//
//struct DescriptionOfEvent: View {
//    let text: String
//    var body: some View {
//        Text(text)
//            .font(.system(size: 20)).foregroundColor(.gray)
//            .frame(maxWidth: .infinity, alignment: .center)
//            .multilineTextAlignment(.center)
//            .padding(.bottom, 15)
//    }
//}
//
//struct TimeOfEvent: View {
//    let integer: Int64
//    var body: some View {
//        Text("\(formattedStartTime)")
//            .font(.system(size: 22)).foregroundColor(Color.blue).bold()
//            .frame(maxWidth: .infinity, alignment: .center)
//            .multilineTextAlignment(.center)
//            .padding(6)
//            .overlay(Rectangle().frame(width: nil, height: 2, alignment: .top).foregroundColor(Color.yellow), alignment: .bottom)
//    }
//
//    private var formattedStartTime: String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d - hh:mm a"
//        let date = Date(timeIntervalSince1970: TimeInterval(integer))
//        return dateFormatter.string(from: date)
//        }
//}
//
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

import SwiftUI

// Create the event struct
struct MyEvent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let startTime: Int64
    let endTime: Int64
}

struct MyEvents: Codable {
    var events: [MyEvent]
}

struct ContentView: View {
    @State var events: [MyEvent] = []
    
    // Helper function to group events by time
    private func groupEventsByTime(events: [MyEvent]) -> [String: [MyEvent]] {
        var groupedEvents: [String: [MyEvent]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d - HH:mm"
        
        for event in events {
            let formattedTime = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTime)))
            
            if var group = groupedEvents[formattedTime] {
                group.append(event)
                groupedEvents[formattedTime] = group
            } else {
                groupedEvents[formattedTime] = [event]
            }
        }
        
        return groupedEvents
    }

    // Make your API call to the HackIllinois API event endpoint
    func fetchDataFromAPI(completion: @escaping (MyEvents) -> ()) {
        if let url = URL(string: "https://adonix.hackillinois.org/event/") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        var events = try decoder.decode(MyEvents.self, from: data)
                        
                        // Sort events by name and start time
                        events.events.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                        events.events.sort { $0.startTime < $1.startTime }
                       
                        DispatchQueue.main.async {
                            completion(events)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching data: \(error)")
                }
            }.resume()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(groupEventsByTime(events: events).keys).sorted(), id: \.self, content: { key in
                    Section(header: Text(key).font(.system(size: 20)).bold().foregroundColor(.blue)) {
                        ForEach(groupEventsByTime(events: events)[key]!, id: \.id) { event in
                            EventRow(event: event)
                        }
                    }
                })
            }
            .navigationBarTitle("Schedule")
            .onAppear {
                fetchDataFromAPI { myEvents in
                    self.events = myEvents.events
                }
            }
        }
    }
}

struct EventRow: View {
    let event: MyEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.name)
                .font(.headline)
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
