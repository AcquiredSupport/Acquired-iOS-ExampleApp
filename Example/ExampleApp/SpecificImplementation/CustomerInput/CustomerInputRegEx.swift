enum CustomerInputRegEx: String {
    case email = #"^\w+([-+.]\w*)*@\w+([-+.]\w+)*\.\w+([-+.]\w+)*$"#
    case phoneNumber = #"^[+]*[0-9- ()]{7,20}$"#
    case addressField = #"^[A-Za-z:0-9 _:,.-_\/\&]*$"#
    case postCode = #"^[A-Za-z]{1,2}[0-9]{1,2}[A-Za-z]{0,1}[ ]*[0-9]{1}[A-Za-z]{2}$"#
}
