//
//  BubbleTimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
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
#Preview {
    BubbleTimelineItemView(item: .mockedBT)
}
