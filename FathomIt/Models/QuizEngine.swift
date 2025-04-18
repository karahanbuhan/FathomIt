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
    
    // MARK: - Private helpers
    private func updateScore(accuracy: Double) {
        totalAccuracy += accuracy
        questionsAnswered += 1
    }
    
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
    
    private func generateQuestionFromCurrentContext() -> Question {
        // Fix: Use self.currentCategory and self.currentUnit
        guard let currentCategory = self.currentCategory,
              let currentUnit = self.currentUnit,
              let units = ConversionEngine.unitCategories[currentCategory] else {
            fatalError("Invalid state: current category or unit not set properly")
        }
        
        var toUnit = units.keys.randomElement()!
        while toUnit == currentUnit {
            toUnit = units.keys.randomElement()!
        }
        
        let value = Double(Int.random(in: 1...100))
        guard let correctAnswer = ConversionEngine.convert(value: value, from: currentUnit, to: toUnit) else {
            fatalError("Conversion failed")
        }
        
        // Localize unit names using LocalizedStringResource
        let fromKey: String = "unit.\(currentUnit)"
        let toKey: String = "unit.\(toUnit)"
        
        let fromLocalized = fromKey.localized().lowercased()
        let toLocalized = toKey.localized().lowercased()
        
        // Use a localized format string
        let format = "question.format".localized()
        let questionText = String(format: format, Int(value), fromLocalized, toLocalized).replacingOccurrences(of: "  ", with: " ")
        
        return Question(
            value: value,
            fromUnit: currentUnit,
            toUnit: toUnit,
            correctAnswer: correctAnswer,
            questionText: questionText
        )
    }
}
