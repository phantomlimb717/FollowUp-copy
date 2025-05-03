//
//  ContactTimelineView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/03/2025.
//

import SwiftUI

struct BubbleTimelineItemView: View {
    
    // MARK: - Stored Properties
    var item: TimelineItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.body ?? "")
                .fontWeight(.medium)
            HStack {
                Label(title: {
                    Text(item.time.formattedRelativeTimeSinceNow)
                }, icon: {
                    Image(icon: item.icon)
                })
                .font(.footnote)
                Spacer()
            }
            .frame(maxWidth: .greatestFiniteMagnitude)
        }
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .greatestFiniteMagnitude)
        .background(
            RoundedRectangle(
                cornerRadius: Constant.ContactTimeline.cornerRadius)
                .foregroundStyle(.quinary)
        )
    }
}

struct EventTimelineItemView: View {
    
    // MARK: - Stored Properties
    var item: TimelineItem

    var body: some View {
        VStack(alignment: .center) {
            Image(icon: item.icon)
                .padding(.bottom, 5)
            Text(item.title)
                .font(.footnote.bold())
            Text(item.time.formattedRelativeTimeSinceNow)
                .font(.footnote)

        }
        .foregroundStyle(.secondary)
        .padding()
    }
}

struct TimelineItemView: View {
    var item: TimelineItem
    var body: some View {
        switch item.kind {
        case .bubble:
            BubbleTimelineItemView(item: item)
        case .event:
            EventTimelineItemView(item: item)
        }
    }
}

struct ContactTimelineView: View {
    
    // MARK: - Stored Properties
    @State var newCommentText: String = ""
    
    var items: [TimelineItem]
    
    var verticalDivider: some View {
        HStack {
            Rectangle()
                .frame(width: 3, height: 10)
                .foregroundStyle(.quinary)
        }
    }
    
    var addCommentButton: some View {
        TextField("Add Comment", text: $newCommentText, prompt: Text("\(Image(icon: .bubble)) Add Comment"), axis: .vertical)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Constant.ContactTimeline.cornerRadius)
                .stroke(.quaternary)
        )
        .submitLabel(.go)
        .onSubmit {
            self.submitComment()
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 0) {
            
            ForEach(items, id: \.id) { item in
                if items.first?.id != item.id {
                    verticalDivider
                }
                TimelineItemView(item: item)
                if items.last?.id != item.id {
                    verticalDivider
                }
            }
            
            addCommentButton
                .padding(.top)
        }
    }
    
    // MARK: - Functions
    func submitComment() { }
}

#Preview {
    ContactTimelineView(items: [.mockedBT,
                                .mockedCall,
                                .mockedBirthday,
                                .mockedMessage])
        .padding()
        .environmentObject(FollowUpManager.mocked())
}
