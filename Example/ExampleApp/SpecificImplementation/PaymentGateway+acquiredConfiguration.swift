import ACQPaymentGateway
import Foundation

extension PaymentGateway {
    static func acquiredConfiguration(hasDismissButton: Bool = false) -> PaymentGateway? {
        guard let baseUrl = URL(string: "https://qaapi.acquired.com/"),
            let baseHppRL = URL(string: "https://qahpp.acquired.com") else {
            return nil
        }
        let configuration = Configuration(
            companyId: "459",
            companyPass: "re3vKdCG",
            companyHash: "cXaFMLbH",
            companyMidId: "1687",
            baseUrl: baseUrl,
            baseHppUrl: baseHppRL,
            // Rationale: constant needed
            // swiftlint:disable:next avoid_hardcoded_constants
            requestRetryAttempts: 3
        )
        if hasDismissButton {
            let options = ViewControllerPresentationOptions(hasDismissButton: true)
            return PaymentGateway(configuration: configuration, presentationOptions: options)
        } else {
            return PaymentGateway(configuration: configuration)
        }
    }
}
