import Foundation

//final class AstPrinter: Visitor {
//    func visitBinaryExpr(expr: Binary) -> String {
//        parenthesize(
//            name: expr.operator.lexeme,
//            expressions: expr.right, expr.left
//        )
//    }
//    
//    func visitLiteralExpr(expr: Literal) -> String {
//        "\(expr.value)"
//    }
//    
//    func visitGroupingExpr(expr: Grouping) -> String {
//        parenthesize(name: "grouping", expressions: expr.expression)
//    }
//    
//    func visitUnaryExpr(expr: Unary) -> String {
//        parenthesize(name: expr.operator.lexeme, expressions: expr.right)
//    }
//    
//    func print(expr: Expr) -> String {
//        return expr.accept(visitor: self)
//    }
//    
//    private func parenthesize(name: String, expressions: Expr...) -> String {
//        var strBuilder = "(" + name
//        for expr in expressions {
//            strBuilder += " "
//            strBuilder += expr.accept(visitor: self)
//        }
//        strBuilder += ")"
//        return strBuilder
//    }
//}
