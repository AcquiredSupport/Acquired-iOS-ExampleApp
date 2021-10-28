import ACQPaymentGateway
import Foundation

extension Configuration {
    static func acquired() -> Configuration {
        guard let baseUrl = URL(string: "https://qaapi.acquired.com"),
            let baseHppRL = URL(string: "https://qahpp.acquired.com") else {
            fatalError("Acquired base URLAddresses must create URLs")
        }
        return Configuration(
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
    }
}
