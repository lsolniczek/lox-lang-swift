import Foundation

struct Unary: Expr {
    var `operator`: Token
    var right: Expr
    
    func accept<V, R>(visitor: V) throws -> R where V : Visitor, R == V.Value {
        try visitor.visitUnaryExpr(expr: self)
    }
}
