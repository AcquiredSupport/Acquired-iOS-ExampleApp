import Combine
import Foundation

/// CountrySelectionViewModel
class CountrySelectionViewModel: ObservableObject, PickerDataSelectable {
    var placeholder: String? {
        "Select a Country"
    }
    var selectedText: String {
        return selectedCountry.country
    }
    var selectedIndex: Int {
        countries.firstIndex(of: selectedCountry) ?? .zero
    }
    var items: [String] {
        countries.map { $0.country }
    }

    func select(at index: Int) {
        selectedCountry = countries[index]
    }
    /// Selected country
    var selectedCountry = CountryCode(country: "United Kingdom", code: "GB")
    /// Title
    var title: String {
        "Country"
    }
    private var countries: [CountryCode] = {
        let unsortedCountries: [CountryCode] = NSLocale.isoCountryCodes.compactMap {
            guard let country = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: $0) else {
                return nil
            }
            return CountryCode(country: country, code: $0)
        }
        let sortedCountries = unsortedCountries.sorted {
            $0.country.localizedCaseInsensitiveCompare($1.country) == .orderedAscending
        }
        return  sortedCountries
    }()
}
