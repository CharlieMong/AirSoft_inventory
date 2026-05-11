import SwiftUI

struct GunDetailView: View {
    @EnvironmentObject var store: GunStore
    let gun: AirsoftGun
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var newMaintenanceNote = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Header
                GunDetailHeader(gun: gun, onEdit: { showingEditSheet = true })

                // MARK: Quick stats row
                HStack(spacing: 1) {
                    QuickStat(
                        icon: "speedometer",
                        value: gun.fps.map { "\($0)" } ?? "—",
                        unit: "FPS",
                        color: .blue
                    )
                    QuickStat(
                        icon: "bolt.fill",
                        value: gun.joules.map { String(format: "%.2f", $0) } ?? "—",
                        unit: "Joules",
                        color: .yellow
                    )
                    QuickStat(
                        icon: "doc.on.doc.fill",
                        value: gun.magazineCount.map { "\($0)" } ?? "—",
                        unit: "Mags",
                        color: .green
                    )
                    QuickStat(
                        icon: "circle.fill",
                        value: gun.totalRounds.map { "\($0)" } ?? "—",
                        unit: "Total Rds",
                        color: .orange
                    )
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.08), lineWidth: 1))

                // MARK: Info sections
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        DetailSection(title: "FPS & Ballistics", icon: "scope") {
                            DetailRow(label: "FPS (0.20g BB)", value: gun.fps.map { "\($0) fps" })
                            DetailRow(label: "Energy", value: gun.joules.map { String(format: "%.2fJ", $0) })
                            DetailRow(label: "Hop-Up Setting", value: gun.hopUpSetting.nilIfEmpty)
                            DetailRow(label: "BB Weight", value: gun.bbWeight.map { "\($0)g" })
                            DetailRow(label: "Inner Barrel", value: gun.innerBarrelLength.map { "\($0)mm" })
                        }

                        DetailSection(title: "Magazines", icon: "doc.on.doc") {
                            DetailRow(label: "Number of Mags", value: gun.magazineCount.map { "\($0)" })
                            DetailRow(label: "Capacity per Mag", value: gun.magazineCapacity.map { "\($0) rounds" })
                            DetailRow(label: "Total Rounds", value: gun.totalRounds.map { "\($0) rounds" })
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 16) {
                        DetailSection(title: "Battery / Power", icon: "bolt.circle") {
                            DetailRow(label: "Type", value: gun.batteryType == .none ? nil : gun.batteryType.rawValue)
                            DetailRow(label: "Status", value: gun.batteryStatus == .na ? nil : gun.batteryStatus.rawValue,
                                      icon: gun.batteryStatus.icon)
                            DetailRow(label: "Notes", value: gun.batteryNotes.nilIfEmpty)
                        }

                        DetailSection(title: "Purchase", icon: "creditcard") {
                            DetailRow(label: "Price", value: gun.purchasePrice.map { "£\(String(format: "%.2f", $0))" })
                            DetailRow(label: "Date", value: gun.purchaseDate.map {
                                $0.formatted(date: .abbreviated, time: .omitted)
                            })
                            DetailRow(label: "Purchased From", value: gun.purchasedFrom.nilIfEmpty)
                        }

                        if !gun.upgrades.isEmpty {
                            DetailSection(title: "Upgrades & Mods", icon: "wrench.and.screwdriver") {
                                Text(gun.upgrades)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        if !gun.notes.isEmpty {
                            DetailSection(title: "Notes", icon: "note.text") {
                                Text(gun.notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // MARK: Maintenance Log
                MaintenanceLogView(gun: gun, newNote: $newMaintenanceNote) {
                    addMaintenanceEntry()
                }

            }
            .padding(24)
        }
        .navigationTitle(gun.name.isEmpty ? "Gun Detail" : gun.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showingEditSheet = true }) {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            GunFormView(mode: .edit(gun)) { updated in
                store.update(updated)
            }
        }
        .alert("Delete \(gun.name)?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) { store.delete(gun) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func addMaintenanceEntry() {
        let note = newMaintenanceNote.trimmingCharacters(in: .whitespaces)
        guard !note.isEmpty else { return }
        var updated = gun
        updated.maintenanceLog.append(MaintenanceEntry(note: note))
        store.update(updated)
        newMaintenanceNote = ""
    }
}

// MARK: - Header

struct GunDetailHeader: View {
    let gun: AirsoftGun
    let onEdit: () -> Void

    var statusColor: Color {
        switch gun.status {
        case .operational: return .green
        case .maintenance: return .orange
        case .retired:     return .red
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: gun.type.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)

                    Text(gun.name.isEmpty ? "Unnamed Gun" : gun.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                HStack(spacing: 12) {
                    if !gun.brand.isEmpty {
                        Text(gun.brand)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    Text(gun.type.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())

                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(gun.status.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Quick stat tile

struct QuickStat: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color.opacity(0.8))

            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.semibold)

            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}

// MARK: - Detail Section

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String?
    var icon: String? = nil

    var body: some View {
        if let value {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if let icon {
                    Label(value, systemImage: icon)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

// MARK: - Maintenance Log

struct MaintenanceLogView: View {
    let gun: AirsoftGun
    @Binding var newNote: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Maintenance Log", systemImage: "wrench.fill")
                .font(.headline)

            Divider()

            if gun.maintenanceLog.isEmpty {
                Text("No maintenance entries yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(gun.maintenanceLog.reversed()) { entry in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 2) {
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 72, alignment: .leading)
                                Text(entry.date.formatted(date: .omitted, time: .shortened))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(Color.secondary.opacity(0.6))
                                    .frame(width: 72, alignment: .leading)
                            }

                            Rectangle()
                                .fill(Color.accentColor.opacity(0.3))
                                .frame(width: 1)
                                .padding(.top, 2)

                            Text(entry.note)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 8)

                        if entry.id != gun.maintenanceLog.first?.id {
                            Divider()
                        }
                    }
                }
            }

            Divider()

            // Input row
            HStack(spacing: 8) {
                TextField("Log a repair, tune, or maintenance note…", text: $newNote)
                    .textFieldStyle(.plain)
                    .onSubmit(onAdd)

                Button(action: onAdd) {
                    Image(systemName: "return")
                        .foregroundColor(newNote.isEmpty ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(newNote.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Helpers

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
