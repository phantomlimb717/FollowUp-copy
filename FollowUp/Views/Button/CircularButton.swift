//
//  CircularButton.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import SwiftUI

struct CircularButton: View {

    // MARK: - Environment Properties
    @Environment(\.openURL) var openURL

    // MARK: - Stored Properties
    var icon: Constant.Icon
    var getAction: () -> ButtonAction
    var padding: CGFloat = 10.0
    var accentColour: Color = .accent
    var backgroundOpacity: CGFloat = 0.3

    var body: some View {
        Button(action: { getAction().closure() }, label: {
            Image(icon: icon)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15, alignment: .center)
        })
            .accentColor(accentColour)
            .padding(padding)
            .background(accentColour.opacity(backgroundOpacity))
            .clipShape(Circle())
    }
    
    init(
        icon: Constant.Icon,
        action getActionClosure: @escaping () -> ButtonAction,
        padding: CGFloat = 10.0,
        accentColour: Color = .accent,
        backgroundOpacity: CGFloat = 0.3
    ) {
        self.icon = icon
        self.getAction = getActionClosure
        self.padding = padding
        self.accentColour = accentColour
        self.backgroundOpacity = backgroundOpacity
    }
    
    init(
        icon: Constant.Icon,
        action: ButtonAction,
        padding: CGFloat = 10.0,
        accentColour: Color = .accent,
        backgroundOpacity: CGFloat = 0.3
    ) {
        self.init(
            icon: icon,
            action: { action },
            padding: padding,
            accentColour: accentColour,
            backgroundOpacity: backgroundOpacity
        )
    }
}

struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircularButton(icon: .phone, action: .other(action: {}))
            CircularButton(icon: .whatsApp, action: .other(action: {}))

        }.previewLayout(.sizeThatFits)
    }
}
