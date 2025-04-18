import Foundation

class ConversionEngine {
    enum UnitCategory: String, CaseIterable {
        case distance, speed, directionAndAngle, time
    }

    static let unitCategories: [UnitCategory: [String: Double]] = [
        .distance: [
            "nautical_miles": 1852,
            "meters": 1,
            "kilometers": 1000,
            "feet": 0.3048,
            "miles": 1609.34,
            "inches": 0.0254,
            "yards": 0.9144,
            "fathoms": 1.8288,
            "cables": 185.2,
            "shackles": 27.432
        ],
        .speed: [
            "knots": 0.514444,
            "km_per_hour": 0.277778,
            "miles_per_hour": 0.44704,
            "meters_per_second": 1
        ],
        .directionAndAngle: [
            "angle_degrees": 1,
            "angle_minutes": 1.0 / 60,
            "angle_seconds": 1.0 / 3600,
            "rhumb": 11.25,
            "quarter": 90
        ],
        .time: [
            "hours": 3600,
            "minutes": 60,
            "seconds": 1,
            "arc_minutes": 4,
            "arc_degrees": 240
        ]
    ]

    static func convert(value: Double, from fromUnit: String, to toUnit: String) -> Double? {
        guard let category = findCategory(from: fromUnit, to: toUnit),
              let fromFactor = unitCategories[category]?[fromUnit],
              let toFactor = unitCategories[category]?[toUnit] else {
            return nil
        }

        let valueInBase = value * fromFactor
        let result = valueInBase / toFactor

        return result
    }

    static func availableUnits() -> [String] {
        unitCategories.flatMap { $0.value.keys }
    }

    private static func findCategory(from: String, to: String) -> UnitCategory? {
        for (category, units) in unitCategories {
            if units.keys.contains(from) && units.keys.contains(to) {
                return category
            }
        }
        return nil
    }
}
