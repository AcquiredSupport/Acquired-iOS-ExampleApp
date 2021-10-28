import ACQPaymentGateway
import Foundation

// Rationale: Constants needed here
// swiftlint:disable avoid_hardcoded_constants
extension ShippingMethod {
    private static var calendar: Calendar { Calendar.current }
    static var option1: ShippingMethod {
        var shippingMethod = ShippingMethod(
            label: "Shipping Method 1",
            amount: 1001,
            state: .final,
            detail: "Details of payment method 1",
            identifier: "123"
        )
        #if os(iOS)
        if #available(iOS 15, *) {
            let today = Date()
            guard let startComponent = Self.calendar.date(byAdding: .day, value: 1, to: today),
                let endComponent = Self.calendar.date(byAdding: .day, value: 2, to: today),
                let dateRange = try? DateComponentsRange(startDate: startComponent, endDate: endComponent) else {
                return shippingMethod
            }
            shippingMethod.dateComponentsRange = dateRange
        }
        #endif
        return shippingMethod
    }
    static var option2: ShippingMethod {
        var shippingMethod = ShippingMethod(
            label: "Shipping Method 2",
            amount: 2002,
            state: .final,
            detail: "Details of shipping method 2",
            identifier: "456"
        )
        #if os(iOS)
        if #available(iOS 15, *) {
            let today = Date()
            guard let startComponent = Self.calendar.date(byAdding: .day, value: 1, to: today),
                let endComponent = Self.calendar.date(byAdding: .day, value: 3, to: today),
                let dateRange = try? DateComponentsRange(startDate: startComponent, endDate: endComponent) else {
                return shippingMethod
            }
            shippingMethod.dateComponentsRange = dateRange
        }
        #endif
        return shippingMethod
    }
    static var option3: ShippingMethod {
        var shippingMethod = ShippingMethod(
            label: "Shipping Method 3",
            amount: 3003,
            state: .final,
            detail: "Details of shipping method 3",
            identifier: "789"
        )
        #if os(iOS)
        if #available(iOS 15, *) {
            let today = Date()
            guard let startComponent = Self.calendar.date(byAdding: .day, value: 2, to: today),
                let endComponent = Self.calendar.date(byAdding: .day, value: 5, to: today),
                let dateRange = try? DateComponentsRange(startDate: startComponent, endDate: endComponent) else {
                return shippingMethod
            }
            shippingMethod.dateComponentsRange = dateRange
        }
        #endif
        return shippingMethod
    }
    static var option4: ShippingMethod {
        var shippingMethod = ShippingMethod(
            label: "Shipping Method 4",
            amount: 4004,
            state: .final,
            detail: "Details of shipping method 4",
            identifier: "012"
        )
        #if os(iOS)
        if #available(iOS 15, *) {
            let today = Date()
            guard let startComponent = Self.calendar.date(byAdding: .day, value: 2, to: today),
                let endComponent = Self.calendar.date(byAdding: .day, value: 7, to: today),
                let dateRange = try? DateComponentsRange(startDate: startComponent, endDate: endComponent) else {
                return shippingMethod
            }
            shippingMethod.dateComponentsRange = dateRange
        }
        #endif
        return shippingMethod
    }
}
