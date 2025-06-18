//
//  TimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
//

import SwiftUI

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

#Preview {
    VStack {
        TimelineItemView(item: .mockedBT)
        TimelineItemView(item: .mockedCall)
    }
}
