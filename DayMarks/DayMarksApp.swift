import SwiftUI

@main
struct DayMarksApp: App {
    @StateObject private var eventStore = EventStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventStore)
        }
    }
}

