import ACQPaymentGateway
import SwiftUI

/// View Model
class ViewModel: ObservableObject {
    /// Card payment method
    var cardPaymentMethod: ACQWebCardPaymentMethod?
}

// Rationale. body length cannot be shorter
// swiftlint:disable type_body_length
struct AvailablePaymentsView: View {
    @ObservedObject private var viewModel = ViewModel()
    private let paymentGateway = PaymentGateway.acquiredConfiguration()
    @State private var paymentMethods: [PaymentMethod] = []
    // Rationale: Constants needed here
    // swiftlint:disable avoid_hardcoded_constants
    @State private var currencyCodeIso3 = "Error"
    @State private var currencyDigits: Int = -1
    @State var showModal = false

    @ObservedObject var orderSummary: OrderSummary = {
        let paymentItem0 = OrderSummaryItem(label: "Item cost", amount: 1802, state: .final)
        let paymentItem1 = OrderSummaryItem(label: "Sales tax", amount: 200, state: .final)
        let shippingMethod0 = ShippingMethod(
            label: "Shipping Method 1",
            amount: 1001,
            state: .final,
            detail: "Details of payment method 1",
            identifier: "123"
        )
        let shippingMethod1 = ShippingMethod(
            label: "Shipping Method 2",
            amount: 2002,
            state: .final,
            detail: "Details of payment method 2",
            identifier: "456"
        )
        let recipientName = "Acquired.com"
        return OrderSummary(
            lineItems: [paymentItem0, paymentItem1],
            shippingMethods: [shippingMethod0, shippingMethod1],
            recipientName: recipientName
        )
    }()
    // swiftlint:enable avoid_hardcoded_constants

    private var total: AnyView {
        AnyView(
            HStack {
                Text(localizedString(from: "order_total"))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(currencyString(from: orderSummary.totalAmount))
                    .bold()
            }
        )
    }

    private var itemslist: AnyView {
        AnyView(
            ForEach(Array(orderSummary.items.enumerated()), id: \.element.label) { item in
                HStack {
                    Text(item.element.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(currencyString(from: item.element.amount))
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

    @State private var shouldShowStatusAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text(localizedString(from: "payment_summary")).font(.title)
            itemslist
                .padding()
            total
                .padding()
            Spacer()
            Text(localizedString(from: "available_payment_types")).font(.title)
            VStack {
                ForEach(paymentMethods, id: \.nameKey) { paymentMethod in
                    listItem(for: paymentMethod)
                    .onTapGesture {
                        if isAdditionalDataInputRequired(for: paymentMethod) {
                            showModal = true
                            return
                        }
                        cellTapped(paymentMethod)
                    }
                }
            }
            .padding()
            .onAppear(perform: getData)
            .alert(isPresented: $shouldShowStatusAlert) { alert }
            Spacer()
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
                ApplePayButton(type: .buy, style: .black, action: {})
                    .fixedSize()
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
                        showModal = isAdditionalDataInputRequired(for: paymentMethod)
                    }
                )
                .sheet(isPresented: $showModal) {
                    createCustomerInputView(for: paymentMethod)
                    .onDisappear(
                        perform: {
                            guard viewModel.cardPaymentMethod?.contact != nil else {
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
        if let webCardPaymentMethod = paymentMethod as? ACQWebCardPaymentMethod {
            viewModel.cardPaymentMethod = webCardPaymentMethod
            return CustomerInputView { contact in
                print("closure called, contact: \(contact)")
                viewModel.cardPaymentMethod?.contact = contact
                showModal = false
            }
        }
        return nil
    }

    private func currencyString(from amount: Int) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currencyCodeIso3
        let number = NSDecimalNumber(
            mantissa: UInt64(amount),
            exponent: -Int16(currencyDigits),
            isNegative: false
        )
        guard let priceString = currencyFormatter.string(from: number) else {
            return "Error"
        }
        return priceString
    }

    private func isAdditionalDataInputRequired(for paymentmethod: PaymentMethod) -> Bool {
        if case paymentmethod.nameKey = "card" {
            return true
        }
        return false
    }

    private func transaction() throws -> ACQTransaction {
        var merchantOrderId = Date().timeIntervalSince1970.description
        // Rationale: Constants needed here
        // swiftlint:disable:next avoid_hardcoded_constants
        let dateOfBirth = try CalendarDate(year: 1970, month: 3, day: 7)
        merchantOrderId = merchantOrderId.filter { $0 != "." }
        return ACQTransaction(
            transactionType: .authCapture,
            subscriptionType: .initial,
            merchantOrderId: merchantOrderId,
            merchantCustomerId: "5678",
            customerDateOfBirth: dateOfBirth,
            merchantContactUrl: "https://www.acquired.com",
            merchantCustom1: "custom1",
            merchantCustom2: "custom2",
            merchantCustom3: "custom3"
        )
    }

    private func cellTapped(_ paymentMethod: PaymentMethod) {
        // This must be unique for each request
        // So using timeIntervalSince1970 from now,
        // removing "." which is not allowed
        guard let acqTransaction = try? transaction() else {
            return
        }
        pay(with: paymentMethod, for: acqTransaction)
    }

    func pay(with paymentMethod: PaymentMethod, for transaction: ACQTransaction) {
        struct WindowNotASceneDelegate: Error {}
        guard let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let window = delegate.window else {
            display(error: WindowNotASceneDelegate())
            return
        }
        paymentGateway?.pay(
            for: orderSummary,
            with: paymentMethod,
            transaction: transaction,
            window: window
        ) { result in
            switch result {
            case .success(let data):
                print("data: \(String(describing: data))")
                displaySuccess()

            case .failure(let error):
                display(error: error)
            }
            orderSummary.selectedShippingMethod = orderSummary.availableShippingMethods.first
            (paymentMethod as? ACQWebCardPaymentMethod)?.contact = nil
        }
    }

    private func display(error: Error) {
        shouldShowStatusAlert = true
        alertTitle = localizedString(from: "error")
        switch error {
        // Rationale: constants are needed
        // swiftlint:disable avoid_hardcoded_constants
        case let declined as PaymentAuthorizationError.Declined where declined.errorCode == 301:
            alertMessage = localizedString(from: "declined_301_message")

        case let tdsFailure as PaymentAuthorizationError.TdsFailure where tdsFailure.errorCode == 540:
        // swiftlint:enable avoid_hardcoded_constants
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

    private func getData() {
        paymentGateway?.getPaymentData {
            switch $0 {
            case .success(let paymentData):
                let currency = paymentData.currency
                currencyCodeIso3 = currency.currencyCode
                currencyDigits = currency.currencyDigits
                paymentMethods = paymentData.availablePaymentMethods.filter { $0.isActive }

            case .failure(let error):
                display(error: error)
            }
        }
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
