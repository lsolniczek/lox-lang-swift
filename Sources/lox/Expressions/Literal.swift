import Foundation

struct Literal: Expr {
    var value: Any
    
    func accept<V, R>(visitor: V) throws -> R where V : Visitor, R == V.Value {
        try visitor.visitLiteralExpr(expr: self)
    }
}
