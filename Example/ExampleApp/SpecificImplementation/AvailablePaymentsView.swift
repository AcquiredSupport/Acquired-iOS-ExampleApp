import ACQPaymentGateway
import SwiftUI

struct AvailablePaymentsView: View {
    private let paymentManager = PaymentManager()
    // Rationale: Constants needed here
    // swiftlint:disable avoid_hardcoded_constants
    private let declinedCode = 301
    private let tdsFailureCode = 540
    // swiftlint:enable avoid_hardcoded_constants
    @State private var showModal = false
    @State private var shouldShowStatusAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var paymentMethods: [PaymentMethod] = []
    @State private var currency: Currency?

    private var total: AnyView {
        AnyView(
            HStack {
                Text(localizedString(from: "order_total"))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(currency?.formatted(from: paymentManager.orderSummary.totalAmount) ?? "Error")
                    .bold()
            }
        )
    }

    private var itemslist: AnyView {
        AnyView(
            ForEach(Array(paymentManager.orderSummary.items.enumerated()), id: \.element.label) { item in
                HStack {
                    Text(item.element.label).frame(maxWidth: .infinity, alignment: .leading)
                    Text(currency?.formatted(from: item.element.amount) ?? "Error")
                }
            }
        )
    }

    private var paymentMethodsList: AnyView {
        AnyView(
            VStack {
                ForEach(paymentMethods, id: \.nameKey) { paymentMethod in
                    listItem(for: paymentMethod)
                    .onTapGesture {
                        if paymentMethod.isAdditionalDataInputRequired {
                            showModal = true
                            return
                        }
                        cellTapped(paymentMethod)
                    }
                }
            }
        )
    }

    private var alert: Alert {
        Alert(
            title: Text(alertTitle),
            message: Text(alertMessage),
            dismissButton: .default(Text(localizedString(from: "ok")))
        )
    }

    var body: some View {
        VStack {
            Text(localizedString(from: "payment_summary")).font(.title)
            itemslist.padding()
            total.padding()
            Spacer()
            Text(localizedString(from: "available_payment_types")).font(.title)
            paymentMethodsList
                .padding()
                .onAppear(perform: getData)
                .alert(isPresented: $shouldShowStatusAlert) { alert }
            Spacer()
            Text(versionAndBuild).font(.footnote)
        }
    }

    func listItem(for paymentMethod: PaymentMethod) -> AnyView {
        if paymentMethod as? ApplePayPaymentMethod != nil {
            return applePayListItem(for: paymentMethod)
        } else {
            return cardListItem(for: paymentMethod)
        }
    }

    func applePayListItem(for paymentMethod: PaymentMethod) -> AnyView {
        AnyView(
            HStack {
                textView(from: paymentMethod)
                ApplePayButton(type: .buy, style: .black, action: {}).fixedSize()
            }
        )
    }

    func cardListItem(for paymentMethod: PaymentMethod) -> AnyView {
        AnyView(
            HStack {
                textView(from: paymentMethod)
                Button(
                    localizedString(from: "pay"),
                    action: {
                        showModal = paymentMethod.isAdditionalDataInputRequired
                    }
                )
                .sheet(isPresented: $showModal) {
                    createCustomerInputView(for: paymentMethod)
                    .onDisappear(
                        perform: {
                            guard paymentManager.billingContact != nil else {
                                display(error: PaymentError(.userCancelled))
                                return
                            }
                            cellTapped(paymentMethod)
                        }
                    )
                }
            }
        )
    }

    private func textView(from paymentMethod: PaymentMethod) -> AnyView {
        var key = paymentMethod.nameKey
        if key.isEmpty {
            key = "unmapped_payment_type"
        }
        // Rationale: dynamic strings required
        // swiftlint:disable:next nslocalizedstring_key
        let textString = NSLocalizedString(key, comment: key)
        return AnyView(
            Text(textString)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemBackground))
        )
    }

    private func createCustomerInputView(for paymentMethod: PaymentMethod) -> CustomerInputView? {
        if paymentMethod as? ACQWebCardPaymentMethod != nil {
            return CustomerInputView {
                paymentManager.billingContact = $0
                showModal = false
            }
        }
        return nil
    }

    private func cellTapped(_ paymentMethod: PaymentMethod) {
        pay(with: paymentMethod)
    }

    func getData() {
        paymentManager.getPaymentData {
            switch $0 {
            case let .success(paymentData):
                paymentMethods = paymentData.availablePaymentMethods.filter({ $0.isActive == true })
                currency = paymentData.currency

            case let .failure(error):
                display(error: error)
            }
        }
    }

    func pay(with paymentMethod: PaymentMethod) {
        paymentManager.pay(with: paymentMethod) { result in
            switch result {
            case .success(let data):
                print("data: \(String(describing: data))")
                displaySuccess()

            case .failure(let error):
                display(error: error)
            }
        }
    }

    private func display(error: Error) {
        shouldShowStatusAlert = true
        alertTitle = localizedString(from: "error")
        switch error {
        case let declined as PaymentAuthorizationError.Declined where declined.errorCode == declinedCode:
            alertMessage = localizedString(from: "declined_301_message")

        case let tdsFailure as PaymentAuthorizationError.TdsFailure where tdsFailure.errorCode == tdsFailureCode:
            var endString = "."
            if let info = tdsFailure.transactionDetails.cardholderResponseInfo {
                endString = " - \(info)."
            }
            alertMessage = String.localizedStringWithFormat(
                "%@%@",
                localizedString(from: "blocked_540_message"),
                endString
            )

        default:
            var baseErrorMessage = "\(localizedString(from: "details")))"
            if case let baseError as BaseTransactionError = error {
                baseErrorMessage += ": \(String(describing: error))"
                baseErrorMessage += "\ncode = \(baseError.transactionDetails.responseCode ?? "")"
                baseErrorMessage += "\nmessage = \(baseError.transactionDetails.responseMessage ?? "")"
            } else {
                let description = error.localizedDescription
                baseErrorMessage += ": \(description)"
            }
            alertMessage = baseErrorMessage
        }
    }

    private func displaySuccess() {
        shouldShowStatusAlert = true
        alertMessage = localizedString(from: "payment_authorized")
        alertTitle = localizedString(from: "success")
    }

    private func localizedString(from key: String) -> String {
        let comment = key.replacingOccurrences(of: "_", with: " ").capitalized
        // Rationale: NSLocalized Strings are needed here
        // swiftlint:disable:next nslocalizedstring_key
        return NSLocalizedString(key, comment: comment)
    }
}

struct AvailablePaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        AvailablePaymentsView()
    }
}

extension PaymentMethod {
    var isAdditionalDataInputRequired: Bool {
        return nameKey == "card"
    }
}
