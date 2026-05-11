import SwiftUI
import WidgetKit

struct DayMarksEntry: TimelineEntry {
    let date: Date
    let event: CountdownEvent?
}

struct DayMarksProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayMarksEntry {
        DayMarksEntry(date: .now, event: CountdownEvent.examples[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (DayMarksEntry) -> Void) {
        completion(DayMarksEntry(date: .now, event: selectedEvent()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayMarksEntry>) -> Void) {
        let entry = DayMarksEntry(date: .now, event: selectedEvent())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func selectedEvent() -> CountdownEvent? {
        let events = EventStorage.sortedEvents(EventStorage.loadEvents())
        return events.first { !$0.isPast } ?? events.first
    }
}

struct DayMarksWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayMarksEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(event: entry.event)
        case .accessoryRectangular:
            AccessoryRectangularView(event: entry.event)
        case .accessoryInline:
            Text(inlineText)
        default:
            MainWidgetView(event: entry.event)
        }
    }

    private var inlineText: String {
        guard let event = entry.event else { return "没有活动" }
        return "\(event.title) \(abs(event.daysRemaining))天"
    }
}

private struct MainWidgetView: View {
    let event: CountdownEvent?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let event {
                CoverImageView(fileName: event.coverFileName, colorHex: event.colorHex)
                    .containerRelativeFrame([.horizontal, .vertical])

                LinearGradient(colors: [.black.opacity(0.08), .black.opacity(0.68)], startPoint: .top, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline.weight(.bold))
                        .lineLimit(2)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(abs(event.daysRemaining))")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                        Text(event.isPast ? "天前" : "天后")
                            .font(.caption.weight(.bold))
                    }
                }
                .foregroundStyle(.white)
                .padding()
            } else {
                ContentUnavailableView("没有活动", systemImage: "calendar.badge.plus")
            }
        }
    }
}

private struct AccessoryCircularView: View {
    let event: CountdownEvent?

    var body: some View {
        if let event {
            Gauge(value: Double(max(0, min(abs(event.daysRemaining), 365))), in: 0...365) {
                Text(String(event.title.prefix(1)))
            } currentValueLabel: {
                Text("\(abs(event.daysRemaining))")
            }
            .gaugeStyle(.accessoryCircular)
        } else {
            Image(systemName: "calendar")
        }
    }
}

private struct AccessoryRectangularView: View {
    let event: CountdownEvent?

    var body: some View {
        if let event {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(abs(event.daysRemaining)) \(event.isPast ? "天前" : "天后")")
                    .font(.caption.weight(.semibold))
            }
        } else {
            Text("没有活动")
        }
    }
}

struct DayMarksWidget: Widget {
    let kind = "DayMarksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DayMarksProvider()) { entry in
            DayMarksWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("活动倒计时")
        .description("显示置顶或最近活动的倒计时。")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct DayMarksWidgetBundle: WidgetBundle {
    var body: some Widget {
        DayMarksWidget()
    }
}

#Preview(as: .systemSmall) {
    DayMarksWidget()
} timeline: {
    DayMarksEntry(date: .now, event: CountdownEvent.examples[0])
}
