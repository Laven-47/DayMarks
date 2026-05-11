import Foundation

enum EventStorage {
    static let appGroupIdentifier = "group.com.local.DayMarks"
    static let eventsFileName = "events.json"
    static let coversDirectoryName = "Covers"

    static var containerURL: URL {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return appGroupURL
        }

        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var eventsURL: URL {
        containerURL.appendingPathComponent(eventsFileName)
    }

    static var eventsFileExists: Bool {
        FileManager.default.fileExists(atPath: eventsURL.path)
    }

    static var coversURL: URL {
        containerURL.appendingPathComponent(coversDirectoryName, isDirectory: true)
    }

    static func coverURL(fileName: String) -> URL {
        coversURL.appendingPathComponent(fileName)
    }

    static func loadEvents() -> [CountdownEvent] {
        do {
            let data = try Data(contentsOf: eventsURL)
            return try JSONDecoder().decode([CountdownEvent].self, from: data)
        } catch {
            return []
        }
    }

    static func saveEvents(_ events: [CountdownEvent]) throws {
        try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(events)
        try data.write(to: eventsURL, options: [.atomic])
    }

    static func sortedEvents(_ events: [CountdownEvent]) -> [CountdownEvent] {
        events.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }

            if $0.isPast != $1.isPast {
                return !$0.isPast && $1.isPast
            }

            return abs($0.daysRemaining) < abs($1.daysRemaining)
        }
    }
}
