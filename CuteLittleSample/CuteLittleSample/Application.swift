//
//  Application.swift
//  CuteLittleSample
//
//  Created by Jacob Martin on 9/20/23.
//

import ComposableArchitecture
import Analytics

struct Application: Reducer {
    struct State: Equatable {
        var stack = StackState<Path.State>()
    }

    enum Action {
        case setup
        case stack(StackAction<Path.State, Path.Action>)
    }

    @Dependency(\.analytics) var analytics

    var body: some Reducer<State, Action> {
        EmptyReducer()
            .forEach(\.stack, action: /Action.stack) {
                Path()
            }

        analyticsReducer
    }
}
