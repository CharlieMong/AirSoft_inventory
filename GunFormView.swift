import SwiftUI

@main
struct AirsoftArsenalApp: App {
    @StateObject private var store = GunStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Gun…") {
                    NotificationCenter.default.post(name: .addGun, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let addGun = Notification.Name("addGun")
}
