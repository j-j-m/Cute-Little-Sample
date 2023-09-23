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

        // Append an event to the end of the list
        func append(event: Event) {
            events.append(event)
        }

        // Remove and return the first event
        func pop() -> Event? {
            guard !events.isEmpty else {
                return nil
            }
            return events.removeFirst()
        }

        // Check the first event without removing it
        func peek() -> Event? {
            return events.first
        }

        // Check if the queue is empty
        var isEmpty: Bool {
            return events.isEmpty
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

