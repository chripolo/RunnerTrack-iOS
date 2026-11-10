# RunnerTrack iOS — Guía para el asistente de código

Este fichero resume el contexto y las reglas del proyecto. Léelo completo antes de implementar nada. Las decisiones de arquitectura se toman fuera de la sesión de código; aquí solo se implementa.

## 1. Identidad del proyecto

App iOS nativa para corredores principiantes con un plan estructurado hacia una carrera objetivo (10K, media maratón, maratón).

Fase actual: Fase 1. Motor de reglas local, sin API de IA y sin servidor obligatorio.

## 2. Stack técnico

| Capa | Tecnología | Notas |
|---|---|---|
| UI | SwiftUI | iOS 17+ como mínimo funcional; target actual iOS 26.2 |
| Datos locales | SwiftData | Única fuente de verdad |
| Salud | HealthKit | FC reposo, HRV, pasos, sueño |
| Motor de reglas | Swift puro | Sin dependencias externas |
| Backend | — | Fase 2; la app funciona 100 % offline |

Arquitectura: MVVM estricto.

- `Model`: SwiftData.
- `ViewModel`: motor de reglas, zonas, alertas.
- `View`: SwiftUI, cero lógica de negocio.

## 3. Reglas de código (no negociables)

- MVVM estricto: ninguna lógica de negocio en las vistas.
- SwiftData como única fuente de verdad: sin estado duplicado.
- HealthKit: pedir permisos solo cuando se necesiten, nunca en el onboarding.
- Motor de reglas: funciones puras, sin efectos secundarios, testeables unitariamente.
- Nomenclatura: inglés para el código, español para comentarios y documentación.
- Commits atómicos: un commit por entregable mínimo.
- Sin TODO sin fecha: cada TODO indica la semana objetivo (ej.: `// TODO: S3 — integrar HealthKit`).
- `MockHealthDataService` solo en DEBUG, para desarrollar sin Developer Program.

## 4. Modelos SwiftData

- `UserProfile`: datos del corredor, carrera objetivo, ritmo Z2 inicial, FC máxima y umbral, zonas calculadas, disponibilidad semanal.
- `TrainingSession`: fecha, tipo, duración prevista y real, zona prevista, FC y ritmo medios, distancia, sensación (RPE 1–10), notas, completada.
- `DailyMetric`: FC en reposo, HRV, peso, horas de sueño, fatiga subjetiva.
- `WeeklyPlan`: número de semana, bloque, semana del ciclo, volumen objetivo, sesiones.

## 5. Zonas Friel

Entrada: `thresholdHR`. Si no existe, se estima como `maxHR * 0.96`. Redondeo al entero más cercano.

| Zona | Fórmula | Ejemplo (umbral 172 bpm) |
|---|---|---|
| Z1 Recuperación | 0 – umbral × 0,84 | 0 – 144 |
| Z2 Aeróbico | umbral × 0,85 – × 0,89 | 146 – 153 |
| Z3 Tempo | umbral × 0,90 – × 0,94 | 155 – 162 |
| Z4 Umbral | umbral × 0,95 – × 0,99 | 163 – 170 |
| Z5 Máximo | umbral × 1,00 – FC máxima | 172 – 178 |

## 6. Alertas

| Trigger | Condición | Acción |
|---|---|---|
| FC reposo alta | `restingHR > mediaPersonal + 5` | Alerta amarilla |
| HRV baja | `hrv < 50` ms | Alerta amarilla |
| HRV crítica | `hrv < 45` ms | Alerta roja |

Evaluación actual de un solo día. Pendiente: rachas de 3+ y 4+ días con histórico de `DailyMetric` (TODO: S5).

Reglas de carga previstas: no superar un 10 % de volumen semanal respecto a la semana anterior y ciclo 3+1 (tres semanas de carga y una de descarga).

## 7. Progresión de ritmo Z2

Pendiente de diseño. El ritmo inicial sale del test de onboarding.

## 8. MockHealthDataService

Protocolo `HealthDataService`:

- `getRestingHR() async -> Int?`
- `getHRV() async -> Double?`
- `getSteps() async -> Int?`
- `getSleepHours() async -> Double?`

`RealHealthDataService` usa HealthKit y devuelve `nil` ante cualquier fallo. `MockHealthDataService` devuelve valores fijos de ejemplo y solo existe en DEBUG. La app inyecta el servicio desde el punto de entrada.

## 9. Sincronización con backend

Fuera de alcance en Fase 1. La app funciona sin conexión.

## 10. Calendario de desarrollo

Una semana equivale a un entregable mínimo funcional (S1 modelos y onboarding, S2 plan semanal, S3 dashboard y HealthKit, S4 plan y registro de sesión, S5 alertas, S6 métricas, S7 onboarding completo, S8 uso real y correcciones). No se pasa a la siguiente sin completar el mínimo.

## 11. Criterios de MVP

- Onboarding completado.
- Plan semanal generado por el motor local y visible.
- Sesiones marcadas como completadas con nota y sensación.
- FC en reposo y HRV leídas de HealthKit.
- Alertas de sobreentrenamiento funcionando.
- Sin crashes durante una semana de uso.

El MVP no necesita: API de IA, WorkoutKit, iCloud, notificaciones push ni múltiples usuarios.

## 12. Perfil de ejemplo

Perfil de arranque en DEBUG (`ProfileSeeder`): corredor de ejemplo, maratón objetivo el 27-04-2027, umbral 172 bpm, FC máxima 178 bpm, ritmo Z2 inicial 370 s/km, 5 días disponibles a la semana.
