import Foundation

protocol Expr {
    func accept<V: Visitor, R>(visitor: V) throws -> R where R == V.Value
}
protocol Visitor {
    associatedtype Value
    
    func visitBinaryExpr(expr: Binary) throws -> Value
    func visitLiteralExpr(expr: Literal) throws -> Value
    func visitGroupingExpr(expr: Grouping) throws -> Value
    func visitUnaryExpr(expr: Unary) throws -> Value
}
