//
//  ContactTimelineView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/03/2025.
//

import SwiftUI

struct ContactTimelineView: View {
    
    var commentItemView: some View {
        VStack(alignment: .leading) {
            Text("Spoke on the phone, seemed eager to come to Bible Talk.")
                .fontWeight(.medium)
            HStack {
                Label(title: {
                    Text("Thursday 17th, 2:34pm")
                }, icon: {
                    Image(icon: .chatBubbles)
                })
                .font(.footnote)
            }
        }
        .padding()
        .foregroundStyle(.secondary)
        .frame(maxWidth: .greatestFiniteMagnitude)
        .background(
            RoundedRectangle(cornerRadius: Constant.ContactTimeline.cornerRadius)
                .foregroundStyle(.quinary)
        )
//        .overlay(
//            RoundedRectangle(cornerRadius: Constant.ContactTimeline.cornerRadius)
//                .stroke(.tertiary, lineWidth: Constant.ContactTimeline.borderWidth)
//        )
    }
    
    var verticalDivider: some View {
        HStack {
            Divider()
                .frame(width: 3, height: 20)
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
        Button(action: {
            
        }, label: {
            HStack {
                Label(title: {
                    Text("Add Comment")
                        .fontWeight(.medium)
                }, icon: {
                    Image(icon: .pencil)
                })
                .padding()
                Spacer()
            }
        })
        .foregroundStyle(.secondary)
        .frame(maxWidth: .greatestFiniteMagnitude)
        .cornerRadius(Constant.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constant.ContactTimeline.cornerRadius)
                .stroke(.quaternary, lineWidth: Constant.ContactTimeline.borderWidth)
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            commentItemView
            phoneCallItemView
            addCommentButton
        }
    }
}

#Preview {
    ContactTimelineView()
        .padding()
}
