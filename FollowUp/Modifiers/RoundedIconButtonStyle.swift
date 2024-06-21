//
//  RoundedIconButtonStyle.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/08/2023.
//

import Foundation
import SwiftUI

struct RoundedIconButtonStyle: ButtonStyle {
    
    var foregroundColour: Color = .secondary
    var backgroundColour: Color = Color(.tertiarySystemFill)
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
            .foregroundColor(foregroundColour)
            .fontWeight(.semibold)
            .padding(padding)
            .background {
                backgroundColour
            }
            .opacity(opacity(for: configuration))
            .foregroundColor(.white.opacity(opacity(for: configuration)))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func roundedIconButtonStyle(
        foregroundColour: Color = .secondary,
        backgroundColour: Color = Color(.tertiarySystemFill),
        padding: CGFloat = Constant.borderedButtonPadding,
        cornerRadius: CGFloat = Constant.cornerRadius,
        disabled: Bool = false
    ) -> some View {
        self.buttonStyle(
            RoundedIconButtonStyle(
                foregroundColour: foregroundColour,
                backgroundColour: backgroundColour,
                padding: padding,
                cornerRadius: cornerRadius,
                disabled: false
            )
        )
    }
}
