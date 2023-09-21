#if os(iOS)
import SwiftUI
@_spi(Presentation) import ComposableArchitecture
import Transmission

// FIXME: would be wonderful to get this working. its a great idea, but UIKit presentation is mucking something up.
extension View {
  /// Presents a sheet with a hero transition using the given store as a data source for the sheet's content.
  ///
  /// - Parameters:
  ///   - store: A store that is focused on ``PresentationState`` and ``PresentationAction`` for
  ///     a modal. When `store`'s state is non-`nil`, the system passes a store of unwrapped `State`
  ///     and `Action` to the modifier's closure. You use this store to power the content in a sheet
  ///     you create that the system displays to the user. If `store`'s state is `nil`-ed out, the
  ///     system dismisses the currently displayed sheet.
  ///   - onDismiss: The closure to execute when dismissing the modal view.
  ///   - content: A closure returning the content of the modal view.
  public func heroCover<State, Action, Content: View>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (_ store: Store<State, Action>) -> Content
  ) -> some View {
    self.presentation(store: store) { `self`, $item, destination in
        self.presentation($item, transition: .heroMove) { _ in
            destination(content)
        }
    }
  }

  /// Presents a sheet with a hero transition using the given store as a data source for the sheet's content..
  ///
  /// - Parameters:
  ///   - store: A store that is focused on ``PresentationState`` and ``PresentationAction`` for
  ///     a modal. When `store`'s state is non-`nil`, the system passes a store of unwrapped `State`
  ///     and `Action` to the modifier's closure. You use this store to power the content in a sheet
  ///     you create that the system displays to the user. If `store`'s state is `nil`-ed out, the
  ///     system dismisses the currently displayed sheet.
  ///   - toDestinationState: A transformation to extract modal state from the presentation state.
  ///   - fromDestinationAction: A transformation to embed modal actions into the presentation
  ///     action.
  ///   - onDismiss: The closure to execute when dismissing the modal view.
  ///   - content: A closure returning the content of the modal view.
  public func heroCover<State, Action, DestinationState, DestinationAction, Content: View>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    state toDestinationState: @escaping (_ state: State) -> DestinationState?,
    action fromDestinationAction: @escaping (_ destinationAction: DestinationAction) -> Action,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (_ store: Store<DestinationState, DestinationAction>) -> Content
  ) -> some View {
    self.presentation(
      store: store, state: toDestinationState, action: fromDestinationAction
    ) { `self`, $item, destination in

        self.presentation($item, transition: .heroMove) { _ in
            destination(content)
        }
    }
  }
}
#endif