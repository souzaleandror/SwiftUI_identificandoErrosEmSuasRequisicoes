//
//  SnackBarErrorView.swift
//  Vollmed
//
//  Created by ALURA on 13/10/23.
//

import SwiftUI

struct SnackBarErrorView: View {
    
    @Binding var isShowing: Bool
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Text(message)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom, isShowing ? UIApplication.shared.getKeyWindow?.safeAreaInsets.bottom ?? 0 : -100)
    }
}

#Preview {
    SnackBarErrorView(isShowing: .constant(true), message: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo")
}
