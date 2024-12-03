//
//  Page.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/28/24.
//

enum PageA1: String, CaseIterable, Hashable, Codable, Identifiable {
    case pageA11
    case pageA12
    case pageA13

    var id: String { rawValue }
}

enum PageA2: String, CaseIterable, Hashable, Codable, Identifiable {
    case pageA21
    case pageA22
    case pageA23

    var id: String { rawValue }
}

enum PageB1: String, CaseIterable, Hashable, Codable, Identifiable {
    case pageB11
    case pageB12
    case pageB13

    var id: String { rawValue }
}

enum PageB2: String, CaseIterable, Hashable, Codable, Identifiable {
    case pageB21
    case pageB22
    case pageB23

    var id: String { rawValue }
}
