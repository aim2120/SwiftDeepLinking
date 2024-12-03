//
//  RawColorScheme.swift
//  SwiftDeepLinkingExample
//
//  Created by Annalise Mariottini on 12/3/24.
//

import SwiftUI

enum RawColorScheme: String {
    case light
    case dark
    
    var colorScheme: ColorScheme  {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
