import ACQPaymentGateway

/// ShippingDetails - contains info on shipping options related to address changes
enum ShippingDetails {
    /// ChangedShippingContactCompletion
    ///
    /// Closure executed when the shipping contact is changed in  the ApplePay flow
    static let changedShippingContactCompletion: ChangedShippingContactCompletion = { changedContact, closure in
        if changedContact.postalAddress?.isoCountryCode != "GB" {
            let paymentRequestShippingContactUpdate = PaymentRequestShippingContactUpdate(
                errors: [],
                paymentSummaryItems: Self.nonUkOrderSummaryItems,
                shippingMethods: Self.nonUkShippingOptions
            )
            closure(paymentRequestShippingContactUpdate)
        } else {
            let paymentRequestShippingContactUpdate = PaymentRequestShippingContactUpdate(
                errors: [],
                paymentSummaryItems: Self.ukOrderSummaryItems,
                shippingMethods: Self.ukShippingOptions
            )
            closure(paymentRequestShippingContactUpdate)
        }
    }
    /// Order summary items for a UK purchase
    static let ukOrderSummaryItems: [OrderLineItem] = [
        OrderSummaryItem.item1,
        OrderSummaryItem.salesTax
    ]
    /// Order summary items for a non UK purchase
    static let nonUkOrderSummaryItems: [OrderLineItem] = [
        OrderSummaryItem.item2,
        OrderSummaryItem.item3,
        OrderSummaryItem.salesTax
    ]
    /// Shipping options for UK delivery
    static let ukShippingOptions: [ShippingMethod] = [
        ShippingMethod.option1, ShippingMethod.option2
    ]
    /// Shipping options for non UK delivery
    static let nonUkShippingOptions = [
        ShippingMethod.option3, ShippingMethod.option4
    ]
}
