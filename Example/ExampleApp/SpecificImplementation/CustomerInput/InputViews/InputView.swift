import SwiftUI

struct InputView: View {
    @ObservedObject private var viewModel: InputViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title).font(.subheadline)
            HStack {
                TextField(
                    viewModel.placeholder,
                    text: $viewModel.text,
                    onEditingChanged: { _ in
                    },
                    onCommit: {
                        viewModel.validate()
                    }
                )
                .keyboardType(viewModel.keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("\(viewModel.validationIcon)")
            }
        }
    }

    init(viewModel: InputViewModel) {
        self.viewModel = viewModel
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(viewModel: InputViewModel(title: "test", regEx: .addressField))
    }
}
