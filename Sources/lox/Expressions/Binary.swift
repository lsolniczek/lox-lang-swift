import Foundation

struct Binary: Expr {
    var left: Expr
    var `operator`: Token
    var right: Expr
    
    func accept<V, R>(visitor: V) throws -> R where V : Visitor, R == V.Value {
        try visitor.visitBinaryExpr(expr: self)
    }
}
