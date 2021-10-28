import ACQPaymentGateway
import Foundation

// Rationale: Constants needed here
// swiftlint:disable avoid_hardcoded_constants
extension ACQTransaction {
    static func uniqueExample() -> ACQTransaction {
        // This must be unique for each request
        // So using timeIntervalSince1970, removing "." which is not allowed
        var merchantOrderId = Date().timeIntervalSince1970.description
        // Rationale: Constants needed here and force try OK
        // swiftlint:disable:next avoid_hardcoded_constants force_try
        let dateOfBirth = try! CalendarDate(year: 1970, month: 3, day: 7)
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
}
