import Foundation

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var date: Date
    var note: String
    var coverFileName: String?
    var colorHex: String
    var isPinned: Bool
    var reminderDaysBefore: Int?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        note: String = "",
        coverFileName: String? = nil,
        colorHex: String = "2F7DF6",
        isPinned: Bool = false,
        reminderDaysBefore: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.note = note
        self.coverFileName = coverFileName
        self.colorHex = colorHex
        self.isPinned = isPinned
        self.reminderDaysBefore = reminderDaysBefore
        self.createdAt = createdAt
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? 0
    }

    var isPast: Bool {
        daysRemaining < 0
    }

    var displayDate: String {
        date.formatted(.dateTime.year().month(.wide).day())
    }

    static let examples: [CountdownEvent] = [
        CountdownEvent(title: "毕业典礼", date: Calendar.current.date(byAdding: .day, value: 28, to: .now) ?? .now, note: "准备礼服和拍照清单", colorHex: "2F7DF6", isPinned: true, reminderDaysBefore: 3),
        CountdownEvent(title: "日本旅行", date: Calendar.current.date(byAdding: .day, value: 88, to: .now) ?? .now, note: "检查护照、酒店和行程", colorHex: "F05A28")
    ]
}

