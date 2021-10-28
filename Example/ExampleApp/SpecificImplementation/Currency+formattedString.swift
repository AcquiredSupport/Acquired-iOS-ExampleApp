import ACQPaymentGateway
import Foundation

extension Currency {
    /// Currency string formatted using  currncy digits and iso code
    func formatted(from amount: Int) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currencyCode
        let number = NSDecimalNumber(
            mantissa: UInt64(amount),
            exponent: -Int16(currencyDigits),
            isNegative: false
        )
        guard let priceString = currencyFormatter.string(from: number) else {
            return "Error"
        }
        return priceString
    }
}
