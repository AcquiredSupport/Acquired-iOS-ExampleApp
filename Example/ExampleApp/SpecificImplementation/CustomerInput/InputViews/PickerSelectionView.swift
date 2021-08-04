import SwiftUI

struct PickerSelectionView: View {
    var viewModel: PickerDataSelectable

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title).font(.subheadline)
            HStack {
                VStack {
                    TextFieldWithPickerAsInputView(
                        viewModel: viewModel
                    )
                }
                // Rationale: cxonstant needed
                // swiftlint:disable avoid_hardcoded_constants
                .padding(8)
                .border(Color.gray.opacity(0.25))
            }
        }
    }

    init(viewModel: PickerDataSelectable) {
        self.viewModel = viewModel
    }
}

struct CountrySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSelectionView(viewModel: CountrySelectionViewModel())
    }
}
