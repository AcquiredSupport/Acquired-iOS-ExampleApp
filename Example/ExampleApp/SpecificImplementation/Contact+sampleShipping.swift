import ACQPaymentGateway
import Foundation

extension Contact {
    static let sampleShipping: Contact = {
        var name = PersonNameComponents()
        name.givenName = "Joe"
        name.familyName = "Bloggs"
        let address = PostalAddress(
            street: "A Street",
            subLocality: "A Sublocality",
            city: "A City",
            subAdministrativeArea: "A SubArea",
            administrativeArea: "A County",
            postalCode: "HP1 1AA",
            country: "UK",
            isoCountryCode: "GB"
        )
        return Contact(
            name: name,
            postalAddress: address,
            phoneNumber: "+447803177715",
            emailAddress: "test@test.com"
        )
    }()
}
