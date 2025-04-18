import Foundation

class Question {
    let questionText: String
    let correctAnswer: Double
    let fromUnit: String
    let toUnit: String
    let value: Double
    
    init() {
        // Randomly choose a unit category
        let categories = Array(ConversionEngine.unitCategories.keys)
        let randomCategory = categories.randomElement()!
        
        let units = ConversionEngine.unitCategories[randomCategory]!
        let unitKeys = Array(units.keys)
        
        // Pick two different units
        let from = unitKeys.randomElement()!
        var to = unitKeys.randomElement()!
        while to == from {
            to = unitKeys.randomElement()!
        }
        
        self.fromUnit = from
        self.toUnit = to
        self.value = Double(Int.random(in: 1...100))
        
        self.correctAnswer = ConversionEngine.convert(
            value: self.value,
            from: self.fromUnit,
            to: self.toUnit
        ) ?? 0.0
        
        let fromLocalized = "unit.\(fromUnit)".localized().lowercased()
        let toLocalized = "unit.\(toUnit)".localized().lowercased()
        
        // Use the localized unit names in the question text
        // Ensure the format string is also localized if needed, but for now, keep it simple
        self.questionText = String(format: "question.format".localized(), Int(value), fromLocalized, toLocalized)
    }
    
    init(value: Double, fromUnit: String, toUnit: String, correctAnswer: Double, questionText: String) {
        self.value = value
        self.fromUnit = fromUnit
        self.toUnit = toUnit
        self.correctAnswer = correctAnswer
        self.questionText = questionText
    }
}
