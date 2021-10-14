import Foundation

final class Parser {
    private let tokens: [Token]
    private var current = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            Lox.reportError(error as! LoxError)
            return nil
        }
    }
    
    private func expression() throws -> Expr {
        try equality()
    }
    
    private func equality() throws -> Expr {
        var expr = try comparison()
        while(match(types: .equalEqual, .bangEqual)) {
            let opr = previous
            let right = try comparison()
            expr = Binary(left: expr, operator: opr, right: right)
        }
        return expr
    }
    
    private func comparison() throws -> Expr {
        var expr = try term()
        while(match(types: .greater, .greaterEqual, .less, .lessEqual)) {
            let opr = previous
            let right = try term()
            expr = Binary(left: expr, operator: opr, right: right)
        }
        return expr
    }
    
    private func term() throws -> Expr {
        var expr = try factor()
        while(match(types: .minus, .plus)) {
            let opr = previous
            let right = try factor()
            expr = Binary(left: expr, operator: opr, right: right)
        }
        return expr
    }
    
    private func factor() throws -> Expr {
        var expr = try unary()
        while(match(types: .slash, .star)) {
            let opr = previous
            let right = try unary()
            expr = Binary(left: expr, operator: opr, right: right)
        }
        return expr
    }
    
    private func unary() throws -> Expr {
        if(match(types: .minus, .bang)) {
            let opr = previous
            let right = try primary()
            return Unary(operator: opr, right: right)
        }
        return try primary()
    }
    
    private func primary() throws -> Expr {
        if match(types: .true) { return Literal(value: true) }
        if match(types: .false) { return Literal(value: false) }
        if match(types: .nil) { return Literal(value: Nil()) }
        if match(types: .number, .string) {
            return Literal(value: previous.literal ?? "")
        }
        if match(types: .leftParen) {
            let expr = try expression()
            try consume(type: .rightParen)
            return Grouping(expression: expr)
        }
        throw expectedExpressionError()
    }
    
    private func consume(type: TokenType) throws {
        if check(type) {
            advance()
            return
        }
        let line = peek.line
        throw LoxError.unterminatedExpression(line: line)
    }
    
    private func expectedExpressionError() -> LoxError {
        let line = peek.line
        return LoxError.expectedExpression(line: line)
    }
    
    private func synchronize() {
        advance()
        while(!isAtEnd) {
            if previous.type == .semicolon { return }
            switch peek.type {
            case .class, .fun, .var, .for, .if, .while, .print, .return:
                return
            default:
                advance()
            }
        }
    }
    
    private func match(types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                advance()
                return true
            }
        }
        return false
    }
    
    private func check(_ type: TokenType) -> Bool {
        guard !isAtEnd else { return false }
        return peek.type == type
    }
    
    @discardableResult
    private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous
    }
    
    private var isAtEnd: Bool {
        peek.type == .eof
    }
    
    private var peek: Token {
        tokens[current]
    }
    
    private var previous: Token {
        tokens[current - 1]
    }
    
}
