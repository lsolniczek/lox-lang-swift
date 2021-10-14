import Foundation

final class Interpreter: Visitor {
    
    func interpret(expr: Expr) throws {
        do {
            let value = try evaluate(expr)
            print(value)
        } catch {
            Lox.reportError(error as! LoxError)
        }
    }
    
    func visitBinaryExpr(expr: Binary) throws -> Any {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)
        let oper = expr.operator
        
        switch oper.type {
        case .minus, .star, .slash, .greater, .greaterEqual, .less, .lessEqual:
            let ldoub = try isDouble(oper, left)
            let rdoub = try isDouble(oper, right)
            switch (expr.operator.type) {
            case .minus:
                return ldoub - rdoub
            case .star:
                return ldoub * rdoub
            case .slash:
                return ldoub / rdoub
            case .greater:
                return ldoub > rdoub
            case .greaterEqual:
                return ldoub >= rdoub
            case .less:
                return ldoub < rdoub
            case .lessEqual:
                return ldoub <= rdoub
            default:
                throw LoxError.unsupportedOperator(token: oper)
            }
            
        case .plus, .equalEqual, .bangEqual:
            if let ldoub = try? isDouble(oper, left),
               let rdoub = try? isDouble(oper, right) {
                switch oper.type {
                case .plus:
                    return ldoub + rdoub
                case .equalEqual:
                    return isEqual(ldoub, rdoub)
                case .bangEqual:
                    return !isEqual(ldoub, rdoub)
                default:
                    throw LoxError.unsupportedOperator(token: oper)
                }
            }
            if let lstr = try? isString(oper, left),
               let rstr = try? isString(oper, right) {
                switch oper.type {
                case .plus:
                    return lstr + rstr
                case .equalEqual:
                    return isEqual(lstr, rstr)
                case .bangEqual:
                    return !isEqual(lstr, rstr)
                default:
                    throw LoxError.unsupportedOperator(token: oper)
                }
            }
            
            // TODO: not only number
            throw LoxError.operandNotANumber(token: oper)
            
        default:
            throw LoxError.unsupportedOperator(token: oper)
        }
        throw LoxError.unsupportedOperator(token: oper)
    }
    
    func visitLiteralExpr(expr: Literal) throws -> Any {
        expr.value
    }
    
    func visitGroupingExpr(expr: Grouping) throws -> Any {
        try evaluate(expr.expression)
    }
    
    func visitUnaryExpr(expr: Unary) throws -> Any {
        let right = try evaluate(expr.right)
        let oper = expr.operator
        
        switch oper.type {
        case .minus:
            let double = try isDouble(oper, right)
            return -double
        case .bang:
            let truthy = try isTruthy(oper, right)
            return !truthy
        default:
            throw LoxError.unsupportedOperator(token: oper)
        }
    }
    
    private func isTruthy(_ token: Token, _ value: Any) throws -> Bool {
        if let boolValue = value as? Bool {
            return boolValue
        }
        throw LoxError.operandNotABool(token: token)
    }
    
    private func isDouble(_ token: Token, _ value: Any) throws -> Double {
        if let doubleValue = value as? Double {
            return doubleValue
        }
        throw LoxError.operandNotANumber(token: token)
    }
    
    private func isString(_ token: Token, _ value: Any) throws -> String {
        if let stringValue = value as? String {
            return stringValue
        }
        throw LoxError.operandNotAString(token: token)
    }
    
    private func isEqual<V: Equatable>(_ left: V?, _ right: V?) -> Bool {
        guard let left = left, let right = right else { return true }
        return left == right
    }
    
    private func evaluate(_ expr: Expr) throws -> Any {
        try expr.accept(visitor: self)
    }
}
