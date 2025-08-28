//
//  EventTimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
//

import SwiftUI


struct EventTimelineItemView: View {
    
    // MARK: - Stored Properties
    var item: TimelineItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(icon: item.icon)
                    .renderingMode(.template)
                    .padding(.bottom, 5)
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.footnote.bold())
                    Text(item.time.formattedRelativeTimeSinceNow)
                        .font(.footnote)
                }
            }
            
            if let location = item.location, item.event == .firstMet {
                LocationLabel(location: location)
            }

        }
        .padding()
        .overlay {
            RoundedRectangle(cornerSize: .init(width: Constant.ContactTimeline.cornerRadius, height: Constant.ContactTimeline.cornerRadius))
                .stroke(.quinary)
        }
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview {
    EventTimelineItemView(item: .mockedFirstMet)
}
#endif
