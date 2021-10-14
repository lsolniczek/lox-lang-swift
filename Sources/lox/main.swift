import ArgumentParser
import Foundation

var error: LoxError? = nil

enum LoxError: Error {
    case unterminatedString(line: Int)
    case unterminatedExpression(line: Int)
    case unterminatedBlockComment(line: Int)
    case unexpectedToken(line: Int)
    case expectedExpression(line: Int)
    case unsupportedOperator(token: Token)
    case operandNotANumber(token: Token)
    case operandNotAString(token: Token)
    case operandNotABool(token: Token)
    
    var message: String {
        switch self {
        case .unterminatedString(let line):
            return "[line \(line)] ERROR: Unterminated string."
        case .unterminatedExpression(let line):
            return "[line \(line)] ERROR: Expect ')' after expression."
        case .unterminatedBlockComment(let line):
            return "[line \(line)] ERROR: Unterminated block comment."
        case .unexpectedToken(let line):
            return "[line \(line)] ERROR: Unexpected token."
        case .expectedExpression(let line):
            return "[line \(line)] ERROR: Expected expression."
        case .unsupportedOperator(let token):
            return "[line \(token.line)] ERROR: Unsupported operator."
        case .operandNotANumber(let token):
            return "[line \(token.line)] ERROR: Operand must be a number."
        case .operandNotAString(let token):
            return "[line \(token.line)] ERROR: Operand must be a string."
        case .operandNotABool(let token):
            return "[line \(token.line)] ERROR: Operand must be a bool."
        }
    }
}

struct Lox: ParsableCommand {
    @Argument(help: "Path to Lox file.")
    var path: String?
    
    private static let interpreter = Interpreter()

    mutating func run() throws {
        if let filePath = path {
            try Lox.runFile(filePath)
        } else {
            try Lox.runPrompt()
        }
    }
    
    static func reportError(_ loxError: LoxError) {
        error = loxError
    }

    private static func runFile(_ path: String) throws {
        let fileContent = try String(contentsOfFile: path)
        try run(fileContent)
        if let error = error {
            Lox.exit(withError: error)
        }
    }

    private static func runPrompt() throws {
        print("> ", terminator:"")
        while let line = readLine() {
            try run(line)
            
            if let error = error {
                Lox.exit(withError: error)
            }
            
            print(line)
            print("> ", terminator: "")
        }
    }
    
    private static func run(_ source: String) throws {
        let scanner = Scanner(source: source)
        let tokens = scanner.scanTokens()
        let parser = Parser(tokens: tokens)
        let expr = parser.parse()
        if let expr = expr {
            try interpreter.interpret(expr: expr)
        }
    }
}

Lox.main()
