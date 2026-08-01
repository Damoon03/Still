import SwiftUI

struct NewMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isDiscoverable = false
    @State private var shareWithFriends = false
    @State private var shareWithFutureVisitors = false

    private let characterLimit = 300

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StillSpacing.lg) {
                    placeRow
                    textEditorArea
                    discoverabilitySection
                }
                .padding(StillSpacing.md)
            }
            .background(StillColor.background)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "leave here", subtitle: "make this place part of your story") {
                    dismiss()
                }
                .padding(StillSpacing.md)
                .background(StillColor.background)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(StillColor.ink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("new memory")
                        .font(StillFont.heading(15))
                        .foregroundStyle(StillColor.ink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") { dismiss() }
                        .font(StillFont.body(14))
                        .foregroundStyle(StillColor.accent)
                }
            }
        }
    }

    private var placeRow: some View {
        HStack {
            IconAvatar(systemName: "mappin", size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text("dolores park")
                    .font(StillFont.heading(15))
                    .foregroundStyle(StillColor.ink)
                Text("san francisco, ca")
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)
            }
            Spacer()
            Image(systemName: "gearshape")
                .foregroundStyle(StillColor.inkSecondary)
        }
    }

    private var textEditorArea: some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextEditor(text: $text)
                .font(StillFont.body(15))
                .foregroundStyle(StillColor.ink)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 160)
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("what happened here?")
                            .font(StillFont.body(15))
                            .foregroundStyle(StillColor.inkSecondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }

            Text("\(text.count) / \(characterLimit)")
                .font(StillFont.caption(11))
                .foregroundStyle(StillColor.inkSecondary)
        }
    }

    private var discoverabilitySection: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("who can discover this?")
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)

            optionRow(
                icon: "lock",
                title: "private",
                subtitle: "only you",
                isSelected: !isDiscoverable
            ) {
                isDiscoverable = false
            }

            optionRow(
                icon: "eye",
                title: "discoverable",
                subtitle: "share with others",
                isSelected: isDiscoverable
            ) {
                isDiscoverable = true
            }

            if isDiscoverable {
                VStack(alignment: .leading, spacing: StillSpacing.sm) {
                    Text("if discoverable, who?")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)

                    checkboxRow(icon: "person.2", title: "friends", subtitle: "your friends on still", isOn: $shareWithFriends)
                    checkboxRow(icon: "globe", title: "future visitors", subtitle: "people who visit this place", isOn: $shareWithFutureVisitors)
                }
                .padding(.top, StillSpacing.xs)
            }
        }
    }

    private func optionRow(icon: String, title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? StillColor.accent : StillColor.inkSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(StillFont.body(14))
                        .foregroundStyle(StillColor.ink)
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? StillColor.accent : StillColor.inkSecondary)
            }
            .padding(StillSpacing.md)
            .background(isSelected ? StillColor.accentDim : StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func checkboxRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(StillColor.inkSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(StillFont.body(14))
                        .foregroundStyle(StillColor.ink)
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
                Spacer()
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn.wrappedValue ? StillColor.accent : StillColor.inkSecondary)
            }
            .padding(StillSpacing.md)
            .background(StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NewMemoryView()
}
