import ACQPaymentGateway
import SwiftUI

/// PaymentManager - a class to handle the payment logic outside of the View
class PaymentManager {
    enum Failure: Error {
        case unexpectedNilObject
        case windowNotASceneDelegate
    }

    private let cardChangeCompletion: ChangedPaymentCardCompletion = { paymentCard, update in
        var summaryItems = ShippingDetails.ukOrderSummaryItems
        if case .credit = paymentCard.type {
            summaryItems.append(OrderSummaryItem.creditCardSurcharge)
        }
        let paymentRequestPaymentCardUpdate = PaymentRequestPaymentCardUpdate(
            errors: [],
            paymentSummaryItems: summaryItems
        )
        update(paymentRequestPaymentCardUpdate)
    }
    /// Payment Gateway - The entry point for making payments with the SDK
    lazy var paymentGateway: PaymentGateway = {
        let gateway = PaymentGateway(
            configuration: Configuration.acquired(),
            certificatePinner: TrustKitCertificatePinner(.acquired),
            changedPaymentCardCompletion: cardChangeCompletion,
            presentationOptions: ViewControllerPresentationOptions(hasDismissButton: true)
        )
        if #available(iOS 15.0, *) {
            gateway.changedCouponCodeCompletion = { _, update in
                var summaryItems = ShippingDetails.ukOrderSummaryItems
                summaryItems.append(OrderSummaryItem.couponDiscountItem)
                let shippingMethods = ShippingDetails.ukShippingOptions
                let couponCodeUpdate = PaymentRequestCouponCodeUpdate(
                    errors: [],
                    paymentSummaryItems: summaryItems,
                    shippingMethods: shippingMethods
                )
                update(couponCodeUpdate)
            }
        }
        return gateway
    }()
    /// Summary of the order that the user is paying for
    @ObservedObject var orderSummary: OrderSummary = {
        return OrderSummary(
            lineItems: ShippingDetails.ukOrderSummaryItems,
            shippingMethods: ShippingDetails.ukShippingOptions,
            recipientName: "Acquired.com"
        )
    }()
    /// BillingContact for the payment
    var billingContact: Contact?

    /// Get the Payment Data
    func getPaymentData(
        completion: @escaping (Result<PaymentData, Error>) -> Void
    ) {
        paymentGateway.getPaymentData {
            switch $0 {
            case .success(let paymentData):
                completion(
                    .success(paymentData)
                )

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Pay
    /// - Parameters:
    ///   - paymentMethod: The PaymentMethod to use for the payment
    ///   - completion: Details of the Order or Error
    func pay(
        with paymentMethod: PaymentMethod,
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        guard let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let window = delegate.window else {
                completion(.failure(Failure.windowNotASceneDelegate))
            return
        }
        paymentGateway.pay(
            orderSummary: orderSummary,
            method: paymentMethod,
            transaction: ACQTransaction.uniqueExample(),
            window: window,
            shippingContact: Contact.sampleShipping,
            shippingOption: .enabled(
                completion: ShippingDetails.changedShippingContactCompletion
            ),
            billingContact: billingContact
        ) { [weak self] result in
            guard let self = self else {
                completion(.failure(Failure.unexpectedNilObject))
                return
            }
            completion(result)
            self.orderSummary.update(
                lineItems: ShippingDetails.ukOrderSummaryItems,
                shippingMethods: ShippingDetails.ukShippingOptions
            )
            self.billingContact = nil
        }
    }
}
