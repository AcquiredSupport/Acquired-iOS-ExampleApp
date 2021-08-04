import ACQPaymentGateway
import SwiftUI

struct CustomerInputView: View {
    // Rationale: constants required here
    // swiftlint:disable avoid_hardcoded_constants
    private let largeTopPadding: CGFloat = 15
    private let topPadding: CGFloat = 5
    private let minHeight: CGFloat = 50
    // swiftlint:enable avoid_hardcoded_constants
    @ObservedObject private var emailViewModel = InputViewModel(
        title: "Email Address",
        regEx: .email,
        keyboardType: .emailAddress
    )
    @ObservedObject private var phoneNumberViewModel = InputViewModel(
        title: "Phone Number",
        regEx: .phoneNumber,
        keyboardType: .phonePad,
        isInputRequired: false
    )
    @ObservedObject private var addressLine1ViewModel = InputViewModel(title: "Address Line 1", regEx: .addressField)
    @ObservedObject private var addressLine2ViewModel = InputViewModel(
        title: "Address Line 2",
        regEx: .addressField,
        isInputRequired: false
    )
    @ObservedObject private var cityViewModel = InputViewModel(title: "City", regEx: .addressField)
    @ObservedObject private var postCodeViewModel = InputViewModel(title: "Post Code", regEx: .postCode)
    @ObservedObject private var countryViewModel = CountrySelectionViewModel()
    private var buttonAction: (Contact) -> Void
    private var textInputViewModels: [InputViewModel] {
        [
            emailViewModel,
            phoneNumberViewModel,
            addressLine1ViewModel,
            addressLine2ViewModel,
            cityViewModel,
            postCodeViewModel
        ]
    }
    private var isPayEnabled: Bool {
        textInputViewModels.forEach { $0.validate() }
        return !textInputViewModels.contains(where: { !$0.isValidated })
    }
    private var inputViews: AnyView {
        AnyView(
            VStack {
                Spacer().frame(minHeight: largeTopPadding)
                ForEach(textInputViewModels, id: \.id) {
                    InputView(viewModel: $0).padding(.top, topPadding)
                }
                PickerSelectionView(viewModel: countryViewModel)
                    .padding(.top, topPadding)
            }
        )
    }
    var body: some View {
        ScrollView {
            HStack(alignment: .center) {
                Text("Customer Details")
                    .font(.title)
            }
            inputViews
            Spacer().frame(minHeight: minHeight)
            Button("Pay") {
                payPressed()
            }.disabled(!isPayEnabled)
        }
        .padding()
        .onAppear(perform: setDummyText)
    }

    init(action: @escaping (Contact) -> Void) {
        self.buttonAction = action
    }

    private func createContact() -> Contact {
        let address = PostalAddress(
            street: addressLine1ViewModel.text + addressLine2ViewModel.text,
            subLocality: nil,
            city: cityViewModel.text,
            subAdministrativeArea: nil,
            administrativeArea: nil,
            postalCode: postCodeViewModel.text,
            country: countryViewModel.selectedCountry.country,
            isoCountryCode: countryViewModel.selectedCountry.code
        )
        return Contact(
            name: nil,
            postalAddress: address,
            phoneNumber: phoneNumberViewModel.text,
            emailAddress: emailViewModel.text
        )
    }

    private func payPressed() {
        let contact = createContact()
        print("Contact: \(contact)")
        buttonAction(contact)
    }

    private func setDummyText() {
        emailViewModel.text = ACQContactDetails.email
        phoneNumberViewModel.text = ACQContactDetails.phoneNumber
        addressLine1ViewModel.text = ACQContactDetails.addressLine1
        addressLine2ViewModel.text = ACQContactDetails.addressLine2
        cityViewModel.text = ACQContactDetails.city
        postCodeViewModel.text = ACQContactDetails.postCode
        textInputViewModels.forEach { $0.validate() }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var presentingModal = false
    static var previews: some View {
        CustomerInputView(action: { _ in })
    }
}
