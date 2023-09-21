//
//  ContentView.swift
//  CuteLittleSample
//
//  Created by Jacob Martin on 9/20/23.
//

import SwiftUI
import ComposableArchitecture

let explanation = """
This app demonstrates some code I think is really cool.

I hope you enjoy it as much as I do.
"""
extension Application {

    struct ContentView: View {

        let store: StoreOf<Application>

        var body: some View {
            StackNavWrapperView(
                store: store.scope(
                    state: \.stack,
                    action: Action.stack)
            ) {
                VStack {
                    Text(explanation)
                    NavigationLink(
                        state: Path.State
                            .gallery(.init())
                    ) {
                        Text("Lets Go!")
                    }
                    .padding(.top, 100)
                }
                .padding()
                .navigationTitle("Cute Little Sample")
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
