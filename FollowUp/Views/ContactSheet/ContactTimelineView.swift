//
//  ContactTimelineView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/03/2025.
//

import SwiftUI

struct BubbleTimelineItemView: View {
    
    // MARK: - Stored Properties
    var item: BubbleTimelineItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.body)
                .fontWeight(.medium)
            HStack {
                Label(title: {
                    Text(item.time.formattedRelativeTimeSinceNow)
                }, icon: {
                    Image(icon: item.icon)
                })
                .font(.footnote)
            }
        }
        .padding()
        .foregroundStyle(.secondary)
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
    var item: EventTimelineItem

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
    var item: any TimelineItem
    var body: some View {
        switch item.kind {
        case .bubble:
            BubbleTimelineItemView(item: item as! BubbleTimelineItem)
        case .event:
            EventTimelineItemView(item: item as! EventTimelineItem)
        }
    }
}

struct ContactTimelineView: View {
    
    // MARK: - Stored Properties
    @State var newCommentText: String = ""
    
    var items: [any TimelineItem]
    
    var verticalDivider: some View {
        HStack {
            Divider()
                .frame(width: 3, height: 10)
                .background(.quinary)
        }
    }
    
    var phoneCallItemView: some View {
        VStack(alignment: .center) {
            
            verticalDivider
            VStack(alignment: .center, spacing: 10) {
                Image(icon: .phone)
                Text("Thursday 17th, 2:42pm")
                    .font(.footnote)
            }
            .padding()
            verticalDivider
        }
        .foregroundStyle(.secondary)
    }
    
    var addCommentButton: some View {
        TextField("Add Comment", text: $newCommentText, prompt: Text("\(Image(icon: .pencil)) Add Comment"), axis: .vertical)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
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
    ContactTimelineView(items: [BubbleTimelineItem.mockedBT,
                                EventTimelineItem.mockedCall,
                                BubbleTimelineItem.mockedBirthday,
                                EventTimelineItem.mockedMessage])
        .padding()
}
