//
//  GradientButtonStyle.swift
//  FollowUp
//
//  Created by Aaron Baw on 18/02/2023.
//

import Foundation
import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    
    var colours: [Color]
    var padding: CGFloat = Constant.borderedButtonPadding
    var cornerRadius: CGFloat = Constant.cornerRadius
    var disabled: Bool = false
    
    func opacity(for configuration: Configuration) -> CGFloat {
        if disabled { return 0.5 }
        else {
            return configuration.isPressed ? 0.75 : 1
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding)
            .fontWeight(.semibold)
            .background {
                LinearGradient(colors: colours, startPoint: .leading, endPoint: .trailing)
                    .opacity(opacity(for: configuration))
            }
            .opacity(opacity(for: configuration))
            .foregroundColor(.white.opacity(opacity(for: configuration)))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func gradientButtonStyle(
        colours: [Color],
        padding: CGFloat = Constant.borderedButtonPadding,
        cornerRadius: CGFloat = Constant.cornerRadius,
        disabled: Bool = false
    ) -> some View {
        self.buttonStyle(
            GradientButtonStyle(
                colours: colours,
                padding: padding,
                cornerRadius: cornerRadius,
                disabled: disabled
            )
        )
    }
}
