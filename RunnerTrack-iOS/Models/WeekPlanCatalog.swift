import Foundation

// Catálogo de la semana S01 — Bloque A, Mes 1.
// Plan hardcodeado — TODO: S2+ — generar desde el motor de reglas según perfil

/// Ejercicio de fuerza con series×reps y carga
struct ExerciseItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let setsReps: String
    let load: String?
    let icon: String          // SF Symbol
}

/// Sesión planificada de la semana — plantilla inmutable
struct SessionTemplate: Identifiable, Hashable {
    let id = UUID()
    let dayIndex: Int         // 0 = lunes
    let day: String
    let title: String
    let type: SessionType
    let zone: Zone?           // nil = descanso
    let durationMin: Int?
    let detail: String
    let exercises: [ExerciseItem]
    let videoURL: URL?

    init(dayIndex: Int, day: String, title: String, type: SessionType, zone: Zone? = nil,
         durationMin: Int? = nil, detail: String, exercises: [ExerciseItem] = [], videoURL: URL? = nil) {
        self.dayIndex = dayIndex
        self.day = day
        self.title = title
        self.type = type
        self.zone = zone
        self.durationMin = durationMin
        self.detail = detail
        self.exercises = exercises
        self.videoURL = videoURL
    }
}

enum S01Catalog {

    /// Vídeo de referencia de las rutinas de fuerza del Bloque A
    static let strengthVideoURL = URL(string: "https://www.youtube.com/watch?v=ph9MC08ibn4")

    static let routineA: [ExerciseItem] = [
        ExerciseItem(name: "Squat goblet", setsReps: "3×12-15", load: "mancuerna 12.5 kg", icon: "figure.strengthtraining.functional"),
        ExerciseItem(name: "Press mancuerna 1 brazo", setsReps: "3×12-15", load: "12.5 kg", icon: "dumbbell.fill"),
        ExerciseItem(name: "Remo en banco", setsReps: "3×12-15", load: "12.5 kg c/mano", icon: "figure.rower"),
        ExerciseItem(name: "Squat dividido", setsReps: "3×12-15", load: "peso corporal", icon: "figure.strengthtraining.traditional"),
    ]

    static let routineB: [ExerciseItem] = [
        ExerciseItem(name: "Jalones con banda elástica", setsReps: "3×12-15", load: nil, icon: "figure.strengthtraining.traditional"),
        ExerciseItem(name: "Zancada en reversa", setsReps: "3×12-15 c/pierna", load: "peso corporal", icon: "figure.strengthtraining.functional"),
        ExerciseItem(name: "Flexiones", setsReps: "3×fallo", load: "peso corporal", icon: "figure.core.training"),
        ExerciseItem(name: "Jalones banda agarre neutro", setsReps: "3×12-15", load: nil, icon: "figure.strengthtraining.traditional"),
    ]

    /// Rutina C — core, al final del rodaje Z2 del miércoles
    static let routineC: [ExerciseItem] = [
        ExerciseItem(name: "Enrollamiento (crunch controlado)", setsReps: "3×fallo", load: nil, icon: "figure.core.training"),
        ExerciseItem(name: "Acarreo con mancuerna", setsReps: "3×fallo", load: "12.5 kg", icon: "figure.walk"),
    ]

    static let sessions: [SessionTemplate] = [
        SessionTemplate(
            dayIndex: 0, day: "Lunes", title: "Descanso", type: .rest,
            detail: "Día de recuperación total. Caminar está bien; correr, no. El cuerpo asimila la tirada larga del domingo — el descanso también es entrenamiento."
        ),
        SessionTemplate(
            dayIndex: 1, day: "Martes", title: "Trote Z1 + Fuerza A", type: .easyRun, zone: .z1, durationMin: 40,
            detail: "Trote muy suave en Z1, conversación cómoda durante todo el recorrido. Si la FC sube de zona, camina hasta que baje. Al terminar, rutina de fuerza A: empuje, tracción y pierna con mancuerna.",
            exercises: routineA, videoURL: strengthVideoURL
        ),
        SessionTemplate(
            dayIndex: 2, day: "Miércoles", title: "Rodaje Z2", type: .easyRun, zone: .z2, durationMin: 50,
            detail: "Rodaje aeróbico en Z2 — la base de todo el plan. Ritmo constante, FC dentro del rango de principio a fin. Al terminar, rutina C de core: dos ejercicios, sin prisa y con técnica.",
            exercises: routineC
        ),
        SessionTemplate(
            dayIndex: 3, day: "Jueves", title: "Trote Z1 + Fuerza B", type: .easyRun, zone: .z1, durationMin: 40,
            detail: "Trote regenerativo en Z1, igual que el martes: suave de verdad. Después, rutina de fuerza B con banda elástica y peso corporal: tracción, zancada y empuje.",
            exercises: routineB, videoURL: strengthVideoURL
        ),
        SessionTemplate(
            dayIndex: 4, day: "Viernes", title: "Calidad Z3", type: .tempo, zone: .z3, durationMin: 45,
            detail: "La sesión de calidad de la semana. Calienta 15' en Z1-Z2, bloque central de 20' en Z3 controlado (tempo, no carrera), enfría 10' muy suave. Si la FC se dispara, corta el bloque."
        ),
        SessionTemplate(
            dayIndex: 5, day: "Sábado", title: "Descanso", type: .rest,
            detail: "Descanso antes de la tirada larga. Hidratación, comida completa y dormir bien son el entreno de hoy."
        ),
        SessionTemplate(
            dayIndex: 6, day: "Domingo", title: "Tirada larga Z2", type: .longRun, zone: .z2, durationMin: 75,
            detail: "La sesión clave de la semana. Ritmo cómodo en Z2 de principio a fin — la disciplina de no acelerar es lo que construye la base aeróbica. Lleva agua si hace calor."
        ),
    ]
}
