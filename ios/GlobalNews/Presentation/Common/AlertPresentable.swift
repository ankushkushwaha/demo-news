import Combine
import SwiftUI

protocol AlertPresentable: AnyObject, ObservableObject {
    var alertMessage: String? { get set }
}

struct AlertModifier<VM: AlertPresentable>: ViewModifier {
    @ObservedObject var viewModel: VM
    let title: String
    @State private var showAlert = false

    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.alertMessage) { _, newValue in
                if newValue != nil {
                    showAlert = true
                }
            }
            .alert(title, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            }, message: {
                Text(viewModel.alertMessage ?? "")
            })
    }
}

extension View {
    func presentAlert<VM: AlertPresentable>(title: String = "", viewModel: VM) -> some View {
        modifier(AlertModifier(viewModel: viewModel, title: title))
    }
}
