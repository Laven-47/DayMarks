import PhotosUI
import SwiftUI

struct EventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: EventStore

    @State private var draft: CountdownEvent
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var reminderSelection = ReminderSelection.none

    init(event: CountdownEvent) {
        _draft = State(initialValue: event)
        _reminderSelection = State(initialValue: ReminderSelection(days: event.reminderDaysBefore))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CoverImageView(fileName: draft.coverFileName, colorHex: draft.colorHex)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("选择封面", systemImage: "photo")
                    }

                    ColorPaletteView(selectedHex: $draft.colorHex)
                }

                Section("活动") {
                    TextField("活动名称", text: $draft.title)
                    DatePicker("活动日期", selection: $draft.date, displayedComponents: [.date])
                    TextField("备注", text: $draft.note, axis: .vertical)
                        .lineLimit(3...6)
                    Toggle("置顶显示", isOn: $draft.isPinned)
                }

                Section("提醒") {
                    Picker("本地提醒", selection: $reminderSelection) {
                        ForEach(ReminderSelection.allCases) { selection in
                            Text(selection.title).tag(selection)
                        }
                    }
                }
            }
            .navigationTitle(draft.title.isEmpty ? "新增活动" : "编辑活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        draft.reminderDaysBefore = reminderSelection.days
                        store.upsert(draft)
                        dismiss()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                    draft.coverFileName = try? store.saveCoverData(data, for: draft.id)
                }
            }
        }
    }
}

private struct ColorPaletteView: View {
    @Binding var selectedHex: String

    var body: some View {
        HStack {
            Text("主题色")

            Spacer()

            ForEach(String.eventPalette, id: \.self) { hex in
                Button {
                    selectedHex = hex
                } label: {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if selectedHex == hex {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("选择颜色 \(hex)")
            }
        }
    }
}

private enum ReminderSelection: String, CaseIterable, Identifiable {
    case none
    case sameDay
    case oneDay
    case threeDays
    case sevenDays

    var id: String { rawValue }

    init(days: Int?) {
        switch days {
        case 0: self = .sameDay
        case 1: self = .oneDay
        case 3: self = .threeDays
        case 7: self = .sevenDays
        default: self = .none
        }
    }

    var days: Int? {
        switch self {
        case .none: nil
        case .sameDay: 0
        case .oneDay: 1
        case .threeDays: 3
        case .sevenDays: 7
        }
    }

    var title: String {
        switch self {
        case .none: "不提醒"
        case .sameDay: "当天提醒"
        case .oneDay: "提前 1 天"
        case .threeDays: "提前 3 天"
        case .sevenDays: "提前 7 天"
        }
    }
}

