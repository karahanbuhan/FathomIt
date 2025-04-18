import Foundation

extension String {
    func localized() -> String {
        let lanCode = UserDefaults.standard.string(forKey: "selectedLanguage")?.lowercased() ?? "en"
        
        guard
            let bundlePath = Bundle.main.path(forResource: lanCode, ofType: "lproj"),
            let bundle = Bundle(path: bundlePath)
        else { return "" }
        
        return NSLocalizedString(
            self,
            bundle: bundle,
            value: " ",
            comment: ""
        )
    }
}
