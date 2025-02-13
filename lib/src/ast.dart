part of '../math_expressions.dart';

/// The visitor interface for the abstract syntax tree (AST)
/// of an [Expression].
///
/// * A default ("null") visitor is provided with [NullExpressionVisitor],
///   which can act as a base class for visitor implementations.
/// * Provides a fallback for visiting abstract classes in the class hierarchy.
///   This allows future extensions without changing the base interface.
abstract class ExpressionVisitor<T> {
  // Literals
  T visitLiteral(Literal literal);
  T visitNumber(Number literal);
  T visitVector(Vector literal);
  T visitInterval(IntervalLiteral literal);
  T visitVariable(Variable literal);
  T visitBoundVariable(BoundVariable literal);

  // Operators
  T visitUnaryOperator(UnaryOperator op);
  T visitUnaryPlus(UnaryPlus op);
  T visitUnaryMinus(UnaryMinus op);

  T visitBinaryOperator(BinaryOperator op);
  T visitPlus(Plus op);
  T visitMinus(Minus op);
  T visitTimes(Times op);
  T visitDivide(Divide op);
  T visitModulo(Modulo op);
  T visitPower(Power op);

  // Functions
  T visitFunction(MathFunction func);
  T visitDefaultFunction(DefaultFunction func);
  T visitAlgorithmicFunction(AlgorithmicFunction func);
  T visitCustomFunction(CustomFunction func);
  T visitCompositeFunction(CompositeFunction func);

  T visitExponential(Exponential func);
  T visitLog(Log func);
  T visitLn(Ln func);
  T visitRoot(Root func);
  T visitSqrt(Sqrt func);
  T visitSin(Sin func);
  T visitCos(Cos func);
  T visitTan(Tan func);
  T visitAsin(Asin func);
  T visitAcos(Acos func);
  T visitAtan(Atan func);
  T visitAbs(Abs func);
  T visitCeil(Ceil func);
  T visitFloor(Floor func);
  T visitSgn(Sgn func);
  T visitFactorial(Factorial func);
}

/// Default ("null") implementation of the expression visitor.
abstract class NullExpressionVisitor implements ExpressionVisitor<void> {
  // Literals
  @override
  void visitLiteral(Literal literal) {}
  @override
  void visitNumber(Number literal) {}
  @override
  void visitVector(Vector literal) {}
  @override
  void visitInterval(IntervalLiteral literal) {}
  @override
  void visitVariable(Variable literal) {}
  @override
  void visitBoundVariable(BoundVariable literal) {}

  // Operators
  @override
  void visitUnaryOperator(UnaryOperator op) {}
  @override
  void visitUnaryPlus(UnaryPlus op) {}
  @override
  void visitUnaryMinus(UnaryMinus op) {}

  @override
  void visitBinaryOperator(BinaryOperator op) {}
  @override
  void visitPlus(Plus op) {}
  @override
  void visitMinus(Minus op) {}
  @override
  void visitTimes(Times op) {}
  @override
  void visitDivide(Divide op) {}
  @override
  void visitModulo(Modulo op) {}
  @override
  void visitPower(Power op) {}

  // Functions
  @override
  void visitFunction(MathFunction func) {}
  @override
  void visitDefaultFunction(DefaultFunction func) {}
  @override
  void visitAlgorithmicFunction(AlgorithmicFunction func) {}
  @override
  void visitCustomFunction(CustomFunction func) {}
  @override
  void visitCompositeFunction(CompositeFunction func) {}

  @override
  void visitExponential(Exponential func) {}
  @override
  void visitLog(Log func) {}
  @override
  void visitLn(Ln func) {}
  @override
  void visitRoot(Root func) {}
  @override
  void visitSqrt(Sqrt func) {}
  @override
  void visitSin(Sin func) {}
  @override
  void visitCos(Cos func) {}
  @override
  void visitTan(Tan func) {}
  @override
  void visitAsin(Asin func) {}
  @override
  void visitAcos(Acos func) {}
  @override
  void visitAtan(Atan func) {}
  @override
  void visitAbs(Abs func) {}
  @override
  void visitCeil(Ceil func) {}
  @override
  void visitFloor(Floor func) {}
  @override
  void visitSgn(Sgn func) {}
  @override
  void visitFactorial(Factorial func) {}
}
