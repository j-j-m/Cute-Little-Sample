import CoreHaptics
import Utility
import Dependencies

public class HapticEngine {
    private var engine: CHHapticEngine?
    private var task: Task<Void, Never>?


    @Dependency(\.becameActive) var becameActive

    init() {
        do {
            engine = try CHHapticEngine()
            try self.engine?.start()
        } catch {
            print("There was an error creating the haptic engine: \(error)")
        }

        engine?.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")
        }

        engine?.resetHandler = {
            do {
                try self.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }

        // Create the task
        task = Task {
            for await _ in await becameActive() {
                do {
                    try await self.engine?.start()
                } catch {
                    print("Failed to restart the engine: \(error)")
                }
            }
        }
    }

    deinit {
        task?.cancel()
    }

    public func interaction() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play interaction haptic: \(error.localizedDescription).")
        }
    }
}

extension DependencyValues {
    public var haptics: HapticEngine {
      get { self[HapticEngine.self] }
      set { self[HapticEngine.self] = newValue }
    }
}

extension HapticEngine: DependencyKey {
    public static var liveValue: HapticEngine = .init()
}
