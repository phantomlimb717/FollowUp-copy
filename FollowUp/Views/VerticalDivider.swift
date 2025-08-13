//
//  VerticalDivider.swift
//  FollowUp
//
//  Created by Aaron Baw on 25/06/2025.
//

import SwiftUI

struct VerticalDivider: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: Constant.VerticalDivider.defaultWidth, height: Constant.VerticalDivider.defaultHeight)
                .foregroundStyle(.quinary)
        }
    }
}

#if DEBUG
#Preview {
    VerticalDivider()
}
#endif
