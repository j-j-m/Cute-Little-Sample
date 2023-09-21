//
//  CuteLittleSampleApp.swift
//  CuteLittleSample
//
//  Created by Jacob Martin on 9/20/23.
//

import SwiftUI
import ComposableArchitecture
@main
struct CuteLittleSampleApp: App {
    var body: some Scene {
        WindowGroup {
            Application.ContentView(
                store: .init(
                    initialState: .init(),
                    reducer: Application.init
                )
            )
        }
    }
}

