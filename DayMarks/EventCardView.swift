import SwiftUI

struct EventCardView: View {
    let event: CountdownEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                CoverImageView(fileName: event.coverFileName, colorHex: event.colorHex)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(event.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        if event.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.white)
                                .accessibilityLabel("已置顶")
                        }
                    }

                    Text(event.displayDate)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.88))
                }
                .padding(16)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(dayText)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                    Text(event.isPast ? "天前" : "天后")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !event.note.isEmpty {
                    Text(event.note)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
    }

    private var dayText: String {
        "\(abs(event.daysRemaining))"
    }
}

#Preview {
    EventCardView(event: CountdownEvent.examples[0])
        .padding()
}
