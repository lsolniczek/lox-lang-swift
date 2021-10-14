import Foundation
import CoreVideo

final class Scanner {
    var source: String
    
    private var tokens: [Token] = []
    private var start = 0
    private var current = 0
    private var line = 1
    
    private var isAtEnd: Bool {
        current >= source.count
    }
    
    init(source: String) {
        self.source = source
    }
    
    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()
        }
        tokens.append(Token(type: .eof, line: line))
        return tokens
    }
    
    private func scanToken() {
        let char: Character = getCurrentCharAndAdvance()
        switch char {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "{": addToken(.leftBrace)
        case "}": addToken(.rightBrace)
        case ",": addToken(.comma)
        case ".": addToken(.dot)
        case "-": addToken(.minus)
        case "+": addToken(.plus)
        case ";": addToken(.semicolon)
        case "*": addToken(.star)
        case "!":
            let type: TokenType = match("=") ? .bangEqual : .bang
            addToken(type)
        case "=":
            let type: TokenType = match("=") ? .equalEqual : .equal
            addToken(type)
        case "<":
            let type: TokenType = match("=") ? .lessEqual : .less
            addToken(type)
        case ">":
            let type: TokenType = match("=") ? .greaterEqual : .greater
            addToken(type)
        case "/":
            if match("/") {
                oneLineComment()
            } else if match("*") {
                blockComment()
            } else {
                addToken(.slash)
            }
        case " ", "\r", "\t":
            break
        case "\n":
            line += 1
        case "\"":
            extractString()
        default:
            if isDigit(c: char) {
                extractNumber()
            } else if isAlpha(c: char) {
                indentifier()
            } else {
                Lox.reportError(.unexpectedToken(line: line))
            }
        }
    }
    
    private func advance() {
        current += 1
    }
    
    private func getCurrentCharAndAdvance() -> Character {
        let char = getCurrentChar()
        advance()
        return char
    }
    
    private func getCurrentChar() -> Character {
        let index = source.index(source.startIndex, offsetBy: current)
        return source[index]
    }
    
    private func addToken(_ type: TokenType) {
        addToken(type, literal: nil)
    }
    
    private func addToken(_ type: TokenType, literal: Any?) {
        let lexeme = substring()
        tokens.append(Token(type: type, lexeme: lexeme, literal: literal, line: line))
    }
    
    private func match(_ expected: Character) -> Bool {
        guard !isAtEnd else { return false }
        guard getCurrentChar() == expected else { return false }
        advance()
        return true
    }
    
    private func peek() -> Character {
        if isAtEnd { return "\0" }
        let index = source.index(source.startIndex, offsetBy: current)
        return source[index]
    }
    
    private func peekNext() -> Character {
        let offset = current + 1
        if (offset >= source.count) { return "\0" }
        let index = source.index(source.startIndex, offsetBy: offset)
        return source[index]
    }
    
    private func extractString() {
        while (peek() != "\"" && !isAtEnd) {
            if (peek() == "\n") { line += 1 }
            advance()
        }
        if (isAtEnd) {
            Lox.reportError(.unterminatedString(line: line))
            return
        }
        advance()
        let value = substring(from: start+1, to: current-1)
        addToken(.string, literal: value)
    }
    
    private func extractNumber() {
        while (isDigit(c: peek())) { advance() }
        if (peek() == "." && isDigit(c: peekNext())) {
            advance()
            while(isDigit(c: peek())) { advance() }
        }
        let value = Double(substring())
        addToken(.number, literal: value)
    }
    
    private func oneLineComment() {
        while (peek() != "\n" && !isAtEnd) { advance() }
    }
    
    private func blockComment() {
        while (peek() != "*" && !isAtEnd) {
            if (peek() == "\n") { line += 1 }
            advance()
        }
//        if (peek() == "*" && peekNext() != "/") {
//            continue c
//        }
        if (isAtEnd) {
            Lox.reportError(.unterminatedBlockComment(line: line))
            return
        }
        advance()
    }
    
    private func indentifier() {
        while (isAlphaNumeric(c: peek())) { advance() }
        let type = TokenType(rawValue: substring()) ?? .identifier
        addToken(type)
    }
    
    private func isAlphaNumeric(c: Character) -> Bool {
        return isAlpha(c: c) || isDigit(c: c)
    }
    
    private func isAlpha(c: Character) -> Bool {
        return c.isLetter || c == "_"
    }
    
    private func isDigit(c: Character) -> Bool {
        return c.isNumber
    }
    
    private func substring(from: Int? = nil, to: Int? = nil) -> String {
        let startIndex = source.index(source.startIndex, offsetBy: from ?? start)
        let currentIndex = source.index(source.startIndex, offsetBy: to ?? current)
        return String(source[startIndex..<currentIndex])
    }
 }
