//
//  CircularArrowLoadingSpinner.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/10/2024.
//

import SwiftUI

struct CircularArrowLoadingSpinner: View {
    @State private var rotation: Double = 0
    var body: some View {
        Image(icon: .arrowCirclePath)
            .rotationEffect(.degrees(rotation)) // Apply rotation effect
            .onAppear {
                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    self.rotation = 360
                }
            }
            .onDisappear {
                self.rotation = 0
            }
            .padding(4)
            .cornerRadius(.greatestFiniteMagnitude)
            .foregroundColor(.accent)
            .transition(.move(edge: .top).combined(with: .opacity).animation(.easeInOut))
    }
}

#if DEBUG
#Preview {
    CircularArrowLoadingSpinner()
}
#endif
