//
//  TimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
//

import RealmSwift
import SwiftUI

struct TimelineItemView: View {
    @ObservedRealmObject var item: TimelineItem
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
    
    var contentWithMenu: some View {
        content
            .contextMenu {
                if item.kind == .bubble {
                    editButton
                }
                deleteButton
            }
    }
    
    var body: some View {
        if item.isInvalidated {
            EmptyView()
        } else {
            contentWithMenu
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch item.kind {
        case .bubble:
            BubbleTimelineItemView(item: item)
                .animation(.easeInOut, value: item)
        case .event:
            EventTimelineItemView(item: item)
        }
    }
}

// MARK: - Equatable Conformance
//extension TimelineItemView: Equatable {
//    static func == (lhs: TimelineItemView, rhs: TimelineItemView) -> Bool {
//        lhs.item == rhs.item
//    }
//}

#if DEBUG
#Preview {
    VStack {
        TimelineItemView(item: .mockedBT)
        TimelineItemView(item: .mockedCall)
    }
}
#endif
