import Foundation

struct Grouping: Expr {
    var expression: Expr
    
    func accept<V, R>(visitor: V) throws -> R where V : Visitor, R == V.Value {
        try visitor.visitGroupingExpr(expr: self)
    }
}
