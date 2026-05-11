import SwiftUI

enum FormMode {
    case add
    case edit(AirsoftGun)

    var title: String {
        switch self {
        case .add:  return "Add Gun to Arsenal"
        case .edit: return "Edit Gun"
        }
    }

    var gun: AirsoftGun {
        switch self {
        case .add:         return AirsoftGun()
        case .edit(let g): return g
        }
    }
}

struct GunFormView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode
    let onSave: (AirsoftGun) -> Void

    @State private var gun: AirsoftGun

    // FPS / Joules as strings for text field binding
    @State private var fpsText: String = ""
    @State private var joulesText: String = ""
    @State private var bbWeightText: String = ""
    @State private var barrelText: String = ""
    @State private var magsText: String = ""
    @State private var magCapText: String = ""
    @State private var priceText: String = ""
    @State private var hasPurchaseDate: Bool = false

    init(mode: FormMode, onSave: @escaping (AirsoftGun) -> Void) {
        self.mode = mode
        self.onSave = onSave
        let g = mode.gun
        _gun = State(initialValue: g)
        _fpsText = State(initialValue: g.fps.map(String.init) ?? "")
        _joulesText = State(initialValue: g.joules.map { String(format: "%.2f", $0) } ?? "")
        _bbWeightText = State(initialValue: g.bbWeight.map { String($0) } ?? "")
        _barrelText = State(initialValue: g.innerBarrelLength.map(String.init) ?? "")
        _magsText = State(initialValue: g.magazineCount.map(String.init) ?? "")
        _magCapText = State(initialValue: g.magazineCapacity.map(String.init) ?? "")
        _priceText = State(initialValue: g.purchasePrice.map { String(format: "%.2f", $0) } ?? "")
        _hasPurchaseDate = State(initialValue: g.purchaseDate != nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Sheet header
            HStack {
                Text(mode.title)
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                Button("Save") { save() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(gun.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Identity
                    FormSection(title: "Identity", icon: "tag") {
                        FormRow(label: "Name *") {
                            TextField("e.g. Tokyo Marui M4A1 MWS", text: $gun.name)
                                .textFieldStyle(.roundedBorder)
                        }
                        FormRow(label: "Brand") {
                            TextField("e.g. Tokyo Marui", text: $gun.brand)
                                .textFieldStyle(.roundedBorder)
                        }
                        FormRow(label: "Type") {
                            Picker("Type", selection: $gun.type) {
                                ForEach(GunType.allCases) { t in
                                    Label(t.rawValue, systemImage: t.icon).tag(t)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FormRow(label: "Status") {
                            Picker("Status", selection: $gun.status) {
                                ForEach(GunStatus.allCases) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                        }
                    }

                    // MARK: FPS & Hop-Up
                    FormSection(title: "FPS & Hop-Up", icon: "scope") {
                        HStack(spacing: 12) {
                            FormRow(label: "FPS (0.20g)") {
                                TextField("e.g. 350", text: $fpsText)
                                    .textFieldStyle(.roundedBorder)
                            }
                            FormRow(label: "Joules") {
                                TextField("e.g. 1.14", text: $joulesText)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        FormRow(label: "Hop-Up Setting") {
                            TextField("e.g. 3 clicks up, 6mm spacer", text: $gun.hopUpSetting)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack(spacing: 12) {
                            FormRow(label: "BB Weight (g)") {
                                TextField("e.g. 0.28", text: $bbWeightText)
                                    .textFieldStyle(.roundedBorder)
                            }
                            FormRow(label: "Inner Barrel (mm)") {
                                TextField("e.g. 363", text: $barrelText)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }

                    // MARK: Magazines
                    FormSection(title: "Magazines", icon: "doc.on.doc") {
                        HStack(spacing: 12) {
                            FormRow(label: "Number of Mags") {
                                TextField("e.g. 5", text: $magsText)
                                    .textFieldStyle(.roundedBorder)
                            }
                            FormRow(label: "Capacity per Mag (rds)") {
                                TextField("e.g. 120", text: $magCapText)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }

                    // MARK: Battery / Power
                    FormSection(title: "Battery / Power", icon: "bolt.circle") {
                        FormRow(label: "Power Source") {
                            Picker("Battery Type", selection: $gun.batteryType) {
                                ForEach(BatteryType.allCases) { t in
                                    Text(t.rawValue).tag(t)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FormRow(label: "Charge Status") {
                            Picker("Battery Status", selection: $gun.batteryStatus) {
                                ForEach(BatteryStatus.allCases) { s in
                                    Label(s.rawValue, systemImage: s.icon).tag(s)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FormRow(label: "Battery Notes") {
                            TextField("e.g. 2x Gens Ace 1400mAh", text: $gun.batteryNotes)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // MARK: Purchase
                    FormSection(title: "Purchase", icon: "creditcard") {
                        HStack(spacing: 12) {
                            FormRow(label: "Price (£)") {
                                TextField("e.g. 350.00", text: $priceText)
                                    .textFieldStyle(.roundedBorder)
                            }
                            FormRow(label: "Purchased From") {
                                TextField("e.g. Patrol Base", text: $gun.purchasedFrom)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        FormRow(label: "Purchase Date") {
                            Toggle("Set date", isOn: $hasPurchaseDate)
                                .labelsHidden()
                            if hasPurchaseDate {
                                DatePicker("",
                                    selection: Binding(get: { gun.purchaseDate ?? Date() }, set: { gun.purchaseDate = $0 }),
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                            }
                        }
                    }

                    // MARK: Extras
                    FormSection(title: "Upgrades & Notes", icon: "wrench.and.screwdriver") {
                        FormRow(label: "Upgrades / Mods") {
                            TextField("e.g. Prometheus barrel, Gate TITAN, SHS piston", text: $gun.upgrades)
                                .textFieldStyle(.roundedBorder)
                        }
                        FormRow(label: "Notes") {
                            TextEditor(text: $gun.notes)
                                .frame(minHeight: 70)
                                .font(.body)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.15)))
                        }
                    }

                }
                .padding(20)
            }
        }
        .frame(minWidth: 560, minHeight: 600)
    }

    private func save() {
        // Parse numeric fields
        gun.fps = Int(fpsText)
        gun.joules = Double(joulesText)
        gun.bbWeight = Double(bbWeightText)
        gun.innerBarrelLength = Int(barrelText)
        gun.magazineCount = Int(magsText)
        gun.magazineCapacity = Int(magCapText)
        gun.purchasePrice = Double(priceText)
        if !hasPurchaseDate { gun.purchaseDate = nil }
        else if gun.purchaseDate == nil { gun.purchaseDate = Date() }

        onSave(gun)
        dismiss()
    }
}

// MARK: - Form Helpers

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)

            Divider()

            content()
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.08), lineWidth: 1))
    }
}

struct FormRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
