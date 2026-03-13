import SwiftData
import Foundation

@Model
final class BodyMetric {
    var id: UUID
    var date: Date
    var weight: Double?
    var source: String  // "healthkit" or "manual"

    init(
        id: UUID = UUID(),
        date: Date = .now,
        weight: Double? = nil,
        source: String = "manual"
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.source = source
    }

    var weightString: String {
        guard let w = weight else { return "—" }
        return String(format: "%.1f lbs", w)
    }
}
