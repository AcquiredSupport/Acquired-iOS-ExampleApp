import ACQNetworkSecurity

extension PinningConfiguration {
    static let acquired = PinningConfiguration(
        domains: [
            .init(
                domainName: "acquired.com",
                includeSubdomains: true,
                expirationDate: "2021-12-01",
                publicKeyHashes: [
                    "ZXWiYmb2fYA7mv7eDle7j1sPqlmG43d7oRew0vsZk/c=",
                    "WoiWRyIOVNa9ihaBciRSC7XHjliYS9VwUGOIud4PB18="
                ],
                reportURIs: ["https://wwww.acquired.com/trustkit/report"]
            )
        ],
        isLoggingEnabled: true
    )
}
