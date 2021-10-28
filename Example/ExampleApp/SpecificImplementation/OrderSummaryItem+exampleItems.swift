import ACQPaymentGateway

// Rationale: Constants needed here
// swiftlint:disable avoid_hardcoded_constants
extension OrderSummaryItem {
    static let item1 = OrderSummaryItem(
        label: "Item 1",
        amount: 1802,
        state: .final
    )
    static let item2 = OrderSummaryItem(
        label: "Item 2",
        amount: 1000,
        state: .final
    )
    static let item3 = OrderSummaryItem(
        label: "Item 3",
        amount: 3000,
        state: .final
    )
    static let salesTax = OrderSummaryItem(
        label: "Sales tax",
        amount: 200,
        state: .final
    )
    static let creditCardSurcharge = OrderSummaryItem(
        label: "Credit Card Surcharge",
        amount: 300,
        state: .final
    )
    static let couponDiscountItem = OrderSummaryItem(
        label: "Coupon Discount Applied",
        amount: -300,
        state: .final
    )
}
