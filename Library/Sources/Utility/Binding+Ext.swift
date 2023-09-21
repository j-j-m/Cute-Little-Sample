import SwiftUI

extension Binding {
    public func ignoreNil<Wrapped>() -> Binding<Wrapped?> where Optional<Wrapped> == Value {
        return Binding<Wrapped?>(
            get: {
                return self.wrappedValue
            },
            set: { value in
                guard let value else { return }
                self.wrappedValue = value
            }
        )
    }
}

extension Binding where Value: Equatable {
    public func isEqual(to value: Value) -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue == value },
            set: { newValue in
                // Handle the new value if needed.
                // In this simple example, we do nothing with it.
            }
        )
    }
}

extension Binding {
    public func isPresentAndEqual<Wrapped: Equatable>(to comparisonValue: Wrapped) -> Binding<Bool> where Optional<Wrapped> == Value {
        return Binding<Bool>(
            get: {
                return self.wrappedValue == comparisonValue
            },
            set: { newValue in
                if !newValue {
                    self.wrappedValue = nil
                }
                // If newValue is true, we don't change the original binding.
                // It's up to you how you want to handle this case.
            }
        )
    }

    func isPresent() -> Binding<Bool> where Optional<Any> == Value {
        return Binding<Bool>(
            get: {
                return self.wrappedValue != nil
            },
            set: { newValue in
                if !newValue {
                    self.wrappedValue = nil
                }
                // If newValue is true, we don't change the original binding.
                // It's up to you how you want to handle this case.
            }
        )
    }
}
