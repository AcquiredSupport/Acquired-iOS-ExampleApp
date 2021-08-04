import SwiftUI

/// TextFieldWithPickerAsInputView
struct TextFieldWithPickerAsInputView: UIViewRepresentable {
    @State var text: String?

    private let viewModel: PickerDataSelectable
    private let textField = UITextField()
    private let picker = UIPickerView()

    init(viewModel: PickerDataSelectable) {
        self.viewModel = viewModel
    }

    func makeCoordinator() -> TextFieldWithPickerAsInputView.Coordinator {
        Coordinator(textfield: self)
    }

    func makeUIView(context: UIViewRepresentableContext<TextFieldWithPickerAsInputView>) -> UITextField {
        setUpPicker(from: context)
        setUpTextfield(from: context)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldWithPickerAsInputView>) {
        uiView.text = text ?? viewModel.selectedText
    }

    private func setUpPicker(from context: UIViewRepresentableContext<TextFieldWithPickerAsInputView>) {
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        let selectionIndex = viewModel.selectedIndex
        picker.selectRow(selectionIndex, inComponent: .zero, animated: false)
    }

    private func setUpTextfield(from context: UIViewRepresentableContext<TextFieldWithPickerAsInputView>) {
        textField.placeholder = viewModel.placeholder
        textField.text = viewModel.selectedText
        textField.inputView = picker
        textField.delegate = context.coordinator
    }
}

extension TextFieldWithPickerAsInputView {
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
        private let parent: TextFieldWithPickerAsInputView

        init(textfield: TextFieldWithPickerAsInputView) {
            self.parent = textfield
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            // Rationale: constant needed
            // swiftlint:disable:next avoid_hardcoded_constants
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.viewModel.items.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.viewModel.items[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.viewModel.select(at: row)
            parent.text = parent.viewModel.selectedText
            parent.textField.endEditing(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            self.parent.textField.resignFirstResponder()
        }
    }
}
