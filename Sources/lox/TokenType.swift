enum TokenType: String {
    // Single-character tokens.
    case leftParen, rightParen, leftBrace, rightBrace
    case comma, dot, minus, plus, semicolon, slash, star
    
    // One or two character tokens.
    case bang, bangEqual, equal, equalEqual
    case greater, greaterEqual, less, lessEqual
    
    // Literals.
    case identifier, string, number
    
    // Keywords.
    case and, `class`, `else`, `false`, fun
    case `for`, `if`, `nil`, or, print, `return`
    case `super`, this, `true`, `var`, `while`
    
    case eof
}

struct Nil {}
