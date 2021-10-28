import ACQNetworkSecurity
import Core
import TrustKit

/// TrustKit Certifcate Pinner - Uses Trustkit to Pin SSL certifcates during network communication
public class TrustKitCertificatePinner: CertificatePinner {
    private var trustKit: TrustKit
    /// A dictionary of SSL pinning results keyed by domain
    public private(set) var pinningResults: [String: PinningResult] = [:]

    /// Initilaize a new instance
    /// - Parameter config: A configuration file to set up the certificate pinning
    public init(_ config: PinningConfiguration) {
        if config.isLoggingEnabled {
            TrustKit.setLoggerBlock { message in
                PaymentSDKLogger.log(string: "\(message)", category: .certPinning, level: .debug)
            }
        }
        let trustKitConfig: [String: Any] = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: config.domains.reduce(
                into: [:], { result, next in
                    result[next.domainName] = [
                        kTSKIncludeSubdomains: next.includeSubdomains,
                        kTSKExpirationDate: next.expirationDate,
                        kTSKPublicKeyHashes: next.publicKeyHashes,
                        kTSKReportUris: next.reportURIs
                    ]
                }
            )
        ]
        trustKit = TrustKit(configuration: trustKitConfig)
        trustKit.pinningValidatorCallback = { [weak self] result, _, _ in
            switch result.finalTrustDecision {
            case .shouldBlockConnection:
                self?.pinningResults[result.serverHostname] = .pinningFailed

            case .domainNotPinned:
                self?.pinningResults[result.serverHostname] = .notPinned

            case .shouldAllowConnection:
                self?.pinningResults[result.serverHostname] = .pinned

            @unknown default:
                assertionFailure("TrustKit returned an unknown finalTrustDecision")
            }
        }
    }
    /// Helper method for handling authentication challenges received within a `NSURLSessionDelegate`,
    /// `NSURLSessionTaskDelegate` or `WKNavigationDelegate`
    /// - Parameters:
    ///   - challenge: The authentication challenge,
    ///   supplied by the URL loading system to the delegate's challenge handler method.
    ///   - completionHandler: A closure to invoke to respond to the challenge,
    ///   supplied by the URL loading system to the delegate's challenge handler method.
    /// - Returns: YES` if the challenge was handled and the `completionHandler` was successfuly invoked. `
    /// NO` if the challenge could not be handled because it was not for server certificate validation
    /// (ie. the challenge's `authenticationMethod` was not `NSURLAuthenticationMethodServerTrust`).
    public func handle(
        _ challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) -> Bool {
        return trustKit.pinningValidator.handle(challenge, completionHandler: completionHandler)
    }
}
