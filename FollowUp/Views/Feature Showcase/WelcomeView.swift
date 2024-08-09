//
//  WelcomeView.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/02/2023.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        VStack {
            Text(.welcomeScreenTitle)
                .font(.title.bold())
                .padding(.vertical)
                .padding(.top, Constant.verticalPadding * 3)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 30) {
                IndividualFeatureView(
                    icon: .clock,
                    title: .organiseFeatureTitle,
                    description: .organiseFeatureDescription,
                    colour: .single(.blue)
                )
                
                IndividualFeatureView(
                    icon: .target,
                    title: .setGoalsFeatureTitle,
                    description: .setGoalsFeatureDescription,
                    colour: .gradient([.red.opacity(0.6), .red])
                )
                
                IndividualFeatureView(
                    icon: .bolt,
                    title: .autoComposeFeatureTitle,
                    description: .autoComposeFeatureDescription,
                    colour: .gradient([.yellow.opacity(0.6), .yellow])
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack { }
            .sheet(isPresented: .constant(true)) {
                WelcomeView()
            }
    }
}
