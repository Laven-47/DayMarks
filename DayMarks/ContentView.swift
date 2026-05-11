import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: EventStore
    @State private var editorEvent: CountdownEvent?
    @State private var isAddingEvent = false

    var body: some View {
        NavigationStack {
            List {
                if store.visibleEvents.isEmpty {
                    EmptyStateView()
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(store.visibleEvents) { event in
                        EventCardView(event: event)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.togglePinned(event)
                                } label: {
                                    Label(event.isPinned ? "取消置顶" : "置顶", systemImage: event.isPinned ? "pin.slash" : "pin")
                                }
                                .tint(.indigo)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.delete(event)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                editorEvent = event
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("活动倒计时")
            .searchable(text: $store.searchText, prompt: "搜索活动")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle(isOn: $store.showingPastEvents) {
                        Image(systemName: store.showingPastEvents ? "clock.arrow.circlepath" : "calendar")
                    }
                    .toggleStyle(.button)
                    .accessibilityLabel(store.showingPastEvents ? "隐藏已过期活动" : "显示已过期活动")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingEvent = true
                    } label: {
                        Label("新增活动", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingEvent) {
                EventEditorView(event: CountdownEvent(title: "", date: .now))
            }
            .sheet(item: $editorEvent) { event in
                EventEditorView(event: event)
            }
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "还没有活动",
            systemImage: "calendar.badge.plus",
            description: Text("添加一个未来日期，它会只保存在本机并同步给小组件。")
        )
        .frame(maxWidth: .infinity, minHeight: 360)
    }
}

#Preview {
    ContentView()
        .environmentObject(EventStore())
}

