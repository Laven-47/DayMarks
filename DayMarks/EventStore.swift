import Foundation
import PhotosUI
import SwiftUI
import UserNotifications

@MainActor
final class EventStore: ObservableObject {
    @Published private(set) var events: [CountdownEvent] = []
    @Published var searchText = ""
    @Published var showingPastEvents = true

    var visibleEvents: [CountdownEvent] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return EventStorage.sortedEvents(events).filter { event in
            let matchesSearch = trimmedSearch.isEmpty ||
                event.title.localizedCaseInsensitiveContains(trimmedSearch) ||
                event.note.localizedCaseInsensitiveContains(trimmedSearch)
            let matchesPastFilter = showingPastEvents || !event.isPast
            return matchesSearch && matchesPastFilter
        }
    }

    init() {
        load()
    }

    func load() {
        let loaded = EventStorage.loadEvents()
        events = EventStorage.eventsFileExists ? loaded : CountdownEvent.examples
        persist()
    }

    func upsert(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }

        persist()
        scheduleReminder(for: event)
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        removeCoverIfUnused(fileName: event.coverFileName)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
        persist()
    }

    func togglePinned(_ event: CountdownEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index].isPinned.toggle()
        persist()
    }

    func saveCoverData(_ data: Data, for eventID: UUID) throws -> String {
        try FileManager.default.createDirectory(at: EventStorage.coversURL, withIntermediateDirectories: true)
        let fileName = "\(eventID.uuidString).jpg"
        try data.write(to: EventStorage.coverURL(fileName: fileName), options: [.atomic])
        return fileName
    }

    private func persist() {
        try? EventStorage.saveEvents(events)
    }

    private func scheduleReminder(for event: CountdownEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])

        guard let daysBefore = event.reminderDaysBefore else { return }
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: event.date) ?? event.date
        guard reminderDate > Date() else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "活动提醒"
            content.body = daysBefore == 0 ? "今天就是 \(event.title)" : "\(event.title) 还有 \(daysBefore) 天"
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    private func removeCoverIfUnused(fileName: String?) {
        guard let fileName else { return }
        let isStillUsed = events.contains { $0.coverFileName == fileName }
        guard !isStillUsed else { return }
        try? FileManager.default.removeItem(at: EventStorage.coverURL(fileName: fileName))
    }
}
