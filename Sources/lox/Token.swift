struct Token {
    var type: TokenType
    var lexeme: String = ""
    var literal: Any? = nil
    var line: Int
}

extension Token: CustomStringConvertible {
    var description: String {
        "\(type.rawValue.uppercased()) \(lexeme) \(literal ?? "")"
    }
}
