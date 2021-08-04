/// Interface describing selectable data for a Picker
protocol PickerDataSelectable {
    /// Title
    var title: String { get }
    /// Placeholder
    var placeholder: String? { get }
    /// Selected text
    var selectedText: String { get }
    /// SelectedIndex
    var selectedIndex: Int { get }
    /// Items
    var items: [String] { get }
    /// Select at index
    func select(at index: Int)
}
