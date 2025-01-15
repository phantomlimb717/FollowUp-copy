//
//  NewFeaturesView.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/02/2023.
//

import SwiftUI

struct NewFeaturesView: View {
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        VStack {
            Text("New To FollowUp")
                .font(.title.bold())
                .padding(.vertical)
                .padding(.top, Constant.verticalPadding * 3)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 30) {
                
                IndividualFeatureView(
                    icon: .notification,
                    title: "Reminders",
                    description: "Get reminded to reach out to your newest contacts every morning.",
                    colour: .gradient([.red.opacity(0.6), .red])
                )
                
                IndividualFeatureView(
                    icon: .circle,
                    title: "Simpler Conversation Starters",
                    description: "Add new conversation starters straight from the contact sheet.",
                    colour: .gradient([.yellow.opacity(0.6), .yellow])
                )
                
                IndividualFeatureView(
                    icon: .tag,
                    title: "Visible Tags",
                    description: "See tags for each contact at a glance in your contact list.",
                    colour: .single(.blue)
                )
            }
            .padding(.horizontal, 25)

            Spacer()
            
            VStack(spacing: Constant.verticalPadding) {
                Image(icon: .settings)
                    .foregroundColor(.blue)
                Text(.discoverMoreFeaturesHint)
                    .font(.caption.weight(.regular))
                    .foregroundColor(.secondary)
            }.padding()
            
            Button(action: {
                self.dismissAction()
            }, label: {
                Text(.welcomeScreenContinueButtonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)

        }.padding()
    }
}

struct NewFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack { }
            .sheet(isPresented: .constant(true)) {
                NewFeaturesView()
            }
    }
}
