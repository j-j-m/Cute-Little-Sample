//import CoreData
//import Amplitude
//import Secrets

// A real implementation may might look like

//extension AnalyticsClient {
//    public static var live: Self {
//       var client = AnalyticsClient()
//        client.configure = {
//            Amplitude.instance().defaultTracking.sessions = true
//#if DEBUG
//            Amplitude.instance().initializeApiKey(Secrets.shared.amplitude.dev)
//#else
//            Amplitude.instance().initializeApiKey(Secrets.shared.amplitude.prod)
//#endif
//        }
//
//        client.identify = { userId in
//
//            Amplitude.instance().setUserId(userId, startNewSession: false)
//            Branch.getInstance().setRequestMetadataKey("$amplitude_user_id", value: userId)
//            let deviceId = Amplitude.instance().deviceId // shouldnt have to set this twice, but it is not populated after configuring
//            Branch.getInstance().setRequestMetadataKey("$amplitude_device_id", value: deviceId)
//        }
//
//        client.track = { event in
//            Amplitude.instance().logEvent(event.name, withEventProperties: event.properties)
//        }
//
//       return client
//   }
//}


import Foundation
import os
import CustomDump

enum Log {
    static let subsystem: String = "com.jjm.analytics"
}

private let logger = Logger(subsystem: Log.subsystem,
                            category: "AnalyticsClient")

extension AnalyticsClient {
    public static var dummy: Self {
       var client = AnalyticsClient()
        client.configure = {
            logger.debug("Configured")
        }

        client.identify = { userId in

            logger.debug("Identified with \(userId ?? "nil")")
        }

        client.track = { event in
            let dump = String(customDumping: event)
            logger.debug("Tracked event \(dump)")
        }

       return client
   }
}
