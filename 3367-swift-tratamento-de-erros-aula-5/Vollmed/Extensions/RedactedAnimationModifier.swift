//
//  RedactedAnimationModifier.swift
//  Vollmed
//
//  Created by ALURA on 13/10/23.
//

import SwiftUI

struct RedactedAnimationModifier: ViewModifier {
    @State private var isRedacted = true
    
    func body(content: Content) -> some View {
        content
            .opacity(isRedacted ? 0 : 1)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    self.isRedacted.toggle()
                }
            }
    }
}

extension View {
    func redactedAnimation() -> some View {
        modifier(RedactedAnimationModifier())
    }
}


