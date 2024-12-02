//
//  Sequence+Combine.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/1/24.
//

func combine<S1: Sequence, S2: Sequence>(_ s1: S1, _ s2: S2) -> Array<(S1.Element, S2.Element)> {
    var output: [(S1.Element, S2.Element)] = []
    for es1 in s1 {
        for es2 in s2 {
            output.append((es1, es2))
        }
    }
    return output
}
