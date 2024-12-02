//
//  Color.swift
//  SwiftDeepLinkingExample
//
//  Created by Annalise Mariottini on 12/2/24.
//

import SwiftUI

enum AppColor: String {
    case red
    case blue
    case green

    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        }
    }
}
