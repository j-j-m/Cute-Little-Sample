import Foundation
import Dependencies
import Supabase

// NOTE: I am aware this is insecure, but this is a demo project. we're good :)
private let live = SupabaseClient(
    supabaseURL: URL(string: "https://faijlubrbyuutxxetiwg.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhaWpsdWJyYnl1dXR4eGV0aXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTUyNTczMjUsImV4cCI6MjAxMDgzMzMyNX0.KRtPXTrcAwjbBzjVhecZhaSdC2YnDmCA21NzwmWAAzQ"
)

extension SupabaseClient: TestDependencyKey {
    public static let testValue: SupabaseClient = live
}

extension DependencyValues {
    public var supabase: SupabaseClient {
      get { self[SupabaseClient.self] }
      set { self[SupabaseClient.self] = newValue }
    }
}

extension SupabaseClient: DependencyKey {
    public static var liveValue: SupabaseClient = live
    public static var previewValue: SupabaseClient = live
}


