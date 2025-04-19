import Foundation

class QuizEngine {
    private var score: Int = 0
    private var totalAccuracy: Double = 0.0
    private var questionsAnswered: Int = 0
    
    // These need to be properly initialized
    private var currentCategory: ConversionEngine.UnitCategory?
    private var currentUnit: String?
    
    var debug = false
    var currentQuestion: Question?
    
    // Computed property for average accuracy
    var averageAccuracy: Double {
        return questionsAnswered > 0 ? totalAccuracy / Double(questionsAnswered) : 0
    }
    
    // MARK: - Ask a new question
    func generateQuestion() -> Question {
        // Choose a new category/unit if needed
        if currentCategory == nil || currentUnit == nil {
            let categories = Array(ConversionEngine.unitCategories.keys)
            currentCategory = categories.randomElement()
            
            if let category = currentCategory {
                let units = ConversionEngine.unitCategories[category]!
                currentUnit = Array(units.keys).randomElement()
            }
        }
        
        // Generate a new question within current context
        let question = generateQuestionFromCurrentContext()
        self.currentQuestion = question
        return question
    }
    
    // MARK: - Check user's answer
    func evaluate(answer userAnswer: Double) -> (correctAnswer: Double, accuracy: Double, message: String) {
        guard let question = currentQuestion else {
            return (0, 0, "No question has been asked yet.")
        }
        
        let correct = question.correctAnswer
        let diff = abs(userAnswer - correct)
        let accuracy = max((1.0 - (diff / correct)) * 100.0, 0)
        
        updateScore(accuracy: accuracy)
        adjustDifficulty(accuracy: accuracy)
        
        // Use localized strings for message
        let message = String(format: "answer.format".localized(),
                             correct, accuracy, averageAccuracy)
        
        return (correct, accuracy, message)
    }
    
    // MARK: - Private score and accuracy
    private func updateScore(accuracy: Double) {
        totalAccuracy += accuracy
        questionsAnswered += 1
    }
    
    // MARK: - Adaptive learning
    private func adjustDifficulty(accuracy: Double) {
        guard let currentCategory = currentCategory else { return }
        
        if accuracy < 80 {
            if debug { print("Your accuracy was below 80%. Let's try the same unit again.") }
            // Keep the same unit
        } else if accuracy < 90 {
            if debug { print("Your accuracy was between 80% and 90%. Let's try another unit from the same category.") }
            let units = ConversionEngine.unitCategories[currentCategory]!
            self.currentUnit = units.keys.randomElement()
        } else {
            if debug { print("Great job! Your accuracy was above 90%. Let's try a random question.") }
            let categories = Array(ConversionEngine.unitCategories.keys)
            self.currentCategory = categories.randomElement()
            
            if let newCategory = self.currentCategory {
                let units = ConversionEngine.unitCategories[newCategory]!
                self.currentUnit = units.keys.randomElement()
            }
        }
    }
    
    func generateQuestionFromCurrentContext() -> Question {
        guard let category = currentCategory,
              let unitDict = ConversionEngine.unitCategories[category],
              let fromUnit = unitDict.keys.randomElement(),
              var toUnit = unitDict.keys.randomElement() else {
            fatalError("Invalid unit setup")
        }
        
        // Ensure fromUnit and toUnit are not the same
        while fromUnit == toUnit {
            toUnit = unitDict.keys.randomElement()!
        }

        // Define sensible base unit ranges
        var valueInBase: Double
        switch category {
        case .distance:
            valueInBase = Double.random(in: 0.01...100_000) // meters
        case .speed:
            valueInBase = Double.random(in: 0.1...50) // m/s
        case .directionAndAngle:
            valueInBase = Double.random(in: 0.01...360) // degrees
        case .time:
            valueInBase = Double(Int.random(in: 1...172_800)) // seconds
        case .mass:
            valueInBase = Double.random(in: 0.5...30_000) // kilograms
        }

        // Convert base value to fromUnit
        guard let fromFactor = unitDict[fromUnit],
              let toFactor = unitDict[toUnit] else {
            fatalError("Missing unit conversion factor")
        }

        let fromValue = (valueInBase / fromFactor).rounded(.toNearestOrAwayFromZero)
        var valueInBaseRounded = fromValue * fromFactor
        if valueInBaseRounded == 0 {
            valueInBaseRounded = 1;
        }
        let correctAnswer = valueInBaseRounded / toFactor

        // Build question text
        let fromLocalized = "unit.\(fromUnit)".localized().lowercased()
        let toLocalized = "unit.\(toUnit)".localized().lowercased()
        let questionText = String(format: "question.format".localized(), Int(fromValue), fromLocalized, toLocalized).replacingOccurrences(of: "  ", with: " ")

        return Question(
            value: fromValue,
            fromUnit: fromUnit,
            toUnit: toUnit,
            correctAnswer: correctAnswer,
            questionText: questionText
        )
    }
}
