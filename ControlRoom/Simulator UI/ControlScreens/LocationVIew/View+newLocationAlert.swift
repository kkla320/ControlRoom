import SwiftUI

struct NewLocationAlertViewModifier: ViewModifier {
    @State var newLocationName: String = ""
    
    @Binding var isPresented: Bool
    let action: (String) -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Save location", isPresented: $isPresented) {
                TextField("Name", text: $newLocationName)
                Button {
                    action(newLocationName)
                } label: {
                    Text("Save")
                }
                .disabled(newLocationName.isEmpty)
                
                Button(role: .cancel) {
                    isPresented = false
                } label: {
                    Text("Cancel")
                }
            }
    }
}

extension View {
    func newLocationAlert(
        isPresented: Binding<Bool>,
        action: @escaping (String) -> Void
    ) -> some View {
        modifier(NewLocationAlertViewModifier(
            isPresented: isPresented,
            action: action
        ))
    }
}
