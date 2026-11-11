import SwiftUI
import SwiftData

/// Detalle de una sesión planificada — sheet desde Dashboard o Plan.
/// Si se pasa `session` (TrainingSession de SwiftData), aparece el botón Editar.
struct SessionDetailSheet: View {
    let template: SessionTemplate
    let zoneRangeText: String?
    var isCompleted: Bool = false
    var onToggleComplete: (() -> Void)? = nil
    var session: TrainingSession? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false

    // Estado local del formulario de edición
    @State private var editType: SessionType = .easyRun
    @State private var editDuration: Int = 0
    @State private var editZone: Zone = .z2
    @State private var editFeeling: Int = 5
    @State private var editNotes: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                if isEditing {
                    editForm
                } else {
                    detailContent
                }
            }
            .background(DS.Colors.background)
            .navigationTitle(isEditing ? "Editar sesión" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isEditing, session != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Editar") {
                            loadEditState()
                            withAnimation { isEditing = true }
                        }
                        .foregroundStyle(DS.Colors.accent)
                    }
                }
                if isEditing {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") {
                            withAnimation { isEditing = false }
                        }
                        .foregroundStyle(DS.Colors.textSecondary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Guardar") {
                            saveEdits()
                            withAnimation { isEditing = false }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(DS.Colors.accent)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Vista de detalle (read-only)

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            badges
            Text(template.detail)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
                .lineSpacing(4)

            if !template.exercises.isEmpty {
                exercisesSection
            }

            if let url = template.videoURL {
                Button {
                    openURL(url)
                } label: {
                    Label("Ver vídeo de referencia", systemImage: "play.rectangle.fill")
                        .font(DS.Typo.rowTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(DS.Colors.accent)
            }

            if onToggleComplete != nil {
                completeButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
    }

    // MARK: - Formulario de edición

    private var editForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            editRow(label: "Tipo") {
                Picker("Tipo", selection: $editType) {
                    ForEach(SessionType.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.menu)
                .tint(DS.Colors.accent)
            }

            divider

            editRow(label: "Duración") {
                HStack(spacing: 12) {
                    Text("\(editDuration) min")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .frame(minWidth: 60, alignment: .trailing)
                    Stepper("", value: $editDuration, in: 5...300, step: 5)
                        .labelsHidden()
                }
            }

            divider

            editRow(label: "Zona") {
                Picker("Zona", selection: $editZone) {
                    ForEach(Zone.allCases, id: \.self) { z in
                        Text(z.rawValue).tag(z)
                    }
                }
                .pickerStyle(.segmented)
            }

            divider

            editRow(label: "RPE (1–10)") {
                HStack(spacing: 12) {
                    Text("\(editFeeling)")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .frame(minWidth: 24, alignment: .trailing)
                    Stepper("", value: $editFeeling, in: 1...10)
                        .labelsHidden()
                }
            }

            divider

            VStack(alignment: .leading, spacing: 8) {
                Text("NOTAS")
                    .font(DS.Typo.label)
                    .tracking(1.0)
                    .foregroundStyle(DS.Colors.textSecondary)
                TextEditor(text: $editNotes)
                    .font(DS.Typo.body)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(DS.Colors.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))
                    .frame(minHeight: 100)
            }
            .padding(DS.Layout.cardPadding)
        }
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        .padding(.horizontal, DS.Layout.screenPadding)
        .padding(.top, 16)
    }

    private var divider: some View {
        Divider()
            .overlay(DS.Colors.divider)
            .padding(.leading, DS.Layout.cardPadding)
    }

    private func editRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textPrimary)
            Spacer()
            content()
        }
        .padding(DS.Layout.cardPadding)
    }

    // MARK: - Cabecera

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.day.uppercased())
                .font(DS.Typo.label)
                .tracking(1.5)
                .foregroundStyle(DS.Colors.textSecondary)
            Text(template.title)
                .font(DS.Typo.screenTitle)
                .foregroundStyle(DS.Colors.textPrimary)
            Text(template.type.rawValue)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
        }
    }

    // MARK: - Zona y duración

    private var badges: some View {
        HStack(spacing: 12) {
            if let zone = template.zone {
                HStack(spacing: 8) {
                    Circle()
                        .fill(DS.Colors.zone(zone))
                        .frame(width: 10, height: 10)
                    Text("Zona \(zone.rawValue)")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                    if let range = zoneRangeText {
                        Text(range)
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DS.Colors.surfaceElevated, in: Capsule())
            }
            if let duration = template.durationMin {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Colors.accent)
                    Text("\(duration) min")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DS.Colors.surfaceElevated, in: Capsule())
            }
        }
    }

    // MARK: - Ejercicios de fuerza

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Ejercicios")
            VStack(spacing: 0) {
                ForEach(template.exercises) { exercise in
                    HStack(spacing: 12) {
                        Image(systemName: exercise.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.Colors.accent)
                            .frame(width: 36, height: 36)
                            .background(DS.Colors.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(DS.Typo.rowTitle)
                                .foregroundStyle(DS.Colors.textPrimary)
                            if let load = exercise.load {
                                Text(load)
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }

                        Spacer()

                        Text(exercise.setsReps)
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.accent)
                    }
                    .padding(.vertical, 8)

                    if exercise.id != template.exercises.last?.id {
                        Divider().overlay(DS.Colors.divider)
                    }
                }
            }
            .padding(.horizontal, DS.Layout.cardPadding)
            .padding(.vertical, 8)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
    }

    // MARK: - Botón completar

    private var completeButton: some View {
        Button {
            onToggleComplete?()
            dismiss()
        } label: {
            Label(
                isCompleted ? "Completada" : "Marcar completada",
                systemImage: isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .font(DS.Typo.rowTitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(isCompleted ? DS.Colors.surfaceElevated : DS.Colors.accent)
        .foregroundStyle(isCompleted ? DS.Colors.accent : .black)
    }

    // MARK: - Edit helpers

    private func loadEditState() {
        editType     = session?.type ?? template.type
        editDuration = session?.plannedDuration ?? template.durationMin ?? 30
        editZone     = session?.plannedZone ?? template.zone ?? .z2
        editFeeling  = session?.feeling ?? 5
        editNotes    = session?.notes ?? ""
    }

    private func saveEdits() {
        guard let session else { return }
        session.type            = editType
        session.plannedDuration = editDuration
        session.plannedZone     = editZone
        session.feeling         = editFeeling == 5 && session.feeling == nil ? nil : editFeeling
        session.notes           = editNotes.isEmpty ? nil : editNotes
        try? modelContext.save()
    }
}
