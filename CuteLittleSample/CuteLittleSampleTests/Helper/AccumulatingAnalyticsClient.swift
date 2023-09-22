//
//  AccumulatingAnalyticsClient.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/21/23.
//

import Analytics

extension AnalyticsClient {

    class TestEventStore {
        var events: [Event] = []

        func append(event: Event) {
            events.append(event)
        }
    }

    static func accumulating(in store: TestEventStore) -> Self {
       var client = AnalyticsClient()
        client.configure = { }

        client.identify = { _ in }

        client.track = { event in
            store.append(event: event)
        }

       return client
   }
}
