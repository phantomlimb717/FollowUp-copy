//
//  ChipView.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/07/2023.
//

import SwiftUI

struct ChipView: View {
    
    // MARK: - Stored Properties
    var title: String
    var icon: Constant.Icon?
    var colour: Color = .red
    var action: (() -> Void)? = nil
    var size: Size = .normal

    // MARK: - Views
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            Label(title: {
                Text(title)
                    .lineLimit(1)
                    .frame(maxWidth: size.maxWidth)
                    .truncationMode(.tail)

            }, icon: {
                if let icon = icon {
                    Image(icon: icon)
                }
            })
        })
        .font(size.font)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding)
        .background(colour)
        .cornerRadius(size.cornerRadius)
    }
}

// MARK: - Size Extension
extension ChipView {
    enum Size {
        case normal
        case small
        
        var padding: CGFloat {
            switch self {
            case .normal: return Constant.Tag.Normal.padding
            case .small: return Constant.Tag.Small.padding
            }
        }
        
        var maxWidth: CGFloat {
            switch self {
            case .normal: return Constant.Tag.Normal.maxWidth
            case .small: return Constant.Tag.Small.maxWidth
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .normal: return Constant.Tag.Normal.cornerRadius
            case .small: return Constant.Tag.Small.cornerRadius
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .footnote
            case .normal: return .body
            }
        }
        
    }
}

struct ChipView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ChipView(title: "jj")
            ChipView(title: "Gym", size: .small)
        }
    }
}
