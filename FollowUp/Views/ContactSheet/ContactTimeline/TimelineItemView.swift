//
//  TimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
//

import SwiftUI

struct TimelineItemView: View {
    var item: TimelineItem
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            onEdit?()
        }
    }
    
    var deleteButton: some View {
        Button("Delete", role: .destructive, action: {
            onDelete?()
        })
    }
    
    var body: some View {
        content
            .contextMenu {
                if item.kind == .bubble {
                    editButton
                }
                deleteButton
            }
    }
    
    @ViewBuilder
    var content: some View {
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
