import SwiftUI

struct ContentView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "EN"
    
    @State private var input: String = ""
    @State private var resultMessage: String = ""
    @State private var questionText: String = ""
    
    private var quizEngine = QuizEngine()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                Text("title.name", comment: "App title")
                    .font(.title)
                    .bold()
                
                Text("title.description", comment: "App tagline")
                    .multilineTextAlignment(.center)
                
                Divider()
                
                Text(
                    questionText.isEmpty
                    ? String(localized: "text.question.placeholder", comment: "Question placeholder") : questionText
                )
                .padding()
                
                TextField("textfield.answer.placeholder", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .onSubmit {
                        submitAnswer()
                    }
                
                Button("button.submit") {
                    submitAnswer()
                }
                .buttonStyle(.borderedProminent)
                
                Text(resultMessage)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button("button.next") {
                    askNewQuestion()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .environment(\.locale, getLocale())
            
            // Language Toggle Button
            Button(action: {
                toggleLanguage()
            }) {
                Text(selectedLanguage)
                    .font(.system(size: 14, weight: .bold))
                    .padding(8)
            }
            .buttonStyle(.bordered)
            .padding()
            .help("button.language.help")
        }
        .onAppear {
            askNewQuestion()
        }
        .frame(idealWidth: 150)
    }
    
    // MARK: - Logic
    
    func askNewQuestion() {
        let question = quizEngine.generateQuestion()
        questionText = question.questionText
        input = ""
        resultMessage = ""
    }
    
    func submitAnswer() {
        let sanitizedInput = input.replacingOccurrences(of: ",", with: ".")
        guard let userValue = Double(sanitizedInput) else {
            resultMessage = "answer.invalid".localized()
            return
        }
        
        let (correct, accuracy, _) = quizEngine.evaluate(answer: userValue)
        
        resultMessage = String(format: "answer.format".localized(), correct, accuracy, quizEngine.averageAccuracy)
    }
    
    func toggleLanguage() {
        selectedLanguage = (selectedLanguage == "EN") ? "TR" : "EN"
        // Force UI refresh after language change
        askNewQuestion()
    }
    
    func getLocale() -> Locale {
        return selectedLanguage == "EN" ? Locale(identifier: "en") : Locale(identifier: "tr")
    }
}
