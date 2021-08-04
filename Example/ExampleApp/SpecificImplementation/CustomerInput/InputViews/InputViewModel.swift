import SwiftUI

class InputViewModel: ObservableObject {
    let title: String
    let id = UUID().uuidString
    let placeholder: String
    let keyboardType: UIKeyboardType
    private let regEx: String
    private let isInputRequired: Bool

    var text: String = ""
    @Published var validationIcon = ""
    @Published var isValidated = false {
        didSet {
            validationIcon = isValidated ? "✅" : "❌"
        }
    }

    init(
        title: String,
        regEx: CustomerInputRegEx,
        keyboardType: UIKeyboardType = .default,
        isInputRequired: Bool = true
    ) {
        self.title = title
        self.placeholder = "Enter \(title)"
        self.regEx = regEx.rawValue
        self.keyboardType = keyboardType
        self.isInputRequired = isInputRequired
    }

    func validate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.isInputRequired && self.text.isEmpty {
                self.isValidated = false
                return
            }
            self.isValidated = self.text.range(
                of: self.regEx,
                options: .regularExpression,
                range: nil,
                locale: nil
            ) != nil
        }
    }
}
