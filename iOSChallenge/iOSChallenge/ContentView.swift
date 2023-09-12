//
//  ContentView.swift
//  iOSChallenge
//
//  Created by HackIllinois on 9/6/23.
//


import SwiftUI

// Create the event struct
struct MyEvent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let startTime: Int64
}

struct MyEvents: Codable {
    var events: [MyEvent] //array events with MyEvent objects
}

struct ContentView: View {
    @State var events: [MyEvent] = []
    
    // helper function to group events by time
    private func groupEventsByTime(events: [MyEvent]) -> [String: [MyEvent]] {
        var groupedEvents: [String: [MyEvent]] = [:]
        //https://swiftyplace.com/swift-date-formatting-10-steps-guide/#:~:text=%E2%80%9Cyyyy%E2%80%9D%3A%20Represents%20the%20four,in%20a%2024%2Dhour%20format.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d - HH:mm"
        
        for event in events {
            let formattedTime = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTime)))
            
            if var group = groupedEvents[formattedTime] { //checking if time is already grouped; if yes, then append. if not, then
                group.append(event)                       //create new group
                groupedEvents[formattedTime] = group
            } else {
                groupedEvents[formattedTime] = [event]
            }
        }
        return groupedEvents
    }

    // Make your API call to the HackIllinois API event endpoint
    //from ChatGPT
    func fetchDataFromAPI(completion: @escaping (MyEvents) -> ()) {
        if let url = URL(string: "https://adonix.hackillinois.org/event/") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        var events = try decoder.decode(MyEvents.self, from: data) //organizing the code
                        
                        // Sort events by name and start time
                        events.events.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                       
                        DispatchQueue.main.async {
                            completion(events) //tells computer the sorting has finished
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
            /* from https://medium.com/swift-productions/fetch-json-data-display-list-swiftui-2-0-d301f401c223 */
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
