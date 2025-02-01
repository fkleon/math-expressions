#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:math_expressions/math_expressions.dart';

ContextModel contextModel = ContextModel();
Lexer lexer = Lexer();
ExpressionParser parser = ShuntingYardParser();
Expression? currentExpression;

/// Starts a CLI interpreter for simple mathematical expressions.
void main(List<String> arguments) {
  print('math-expressions interpreter\n');
  print('The following commands are supported:');
  print('  ?            (evaluates the current expression)');
  print('  <var>=<expr> (bind variable <var> to expression)');
  print('  ?<var>       (get variable binding)');
  print(
      '  !<var>       (differentiates the current expression with respect to given <var>)\n');
  print('Please, enter any expression or command.\n');

  for (String input in arguments) {
    print(input);
    wrapParseInput(input);
  }

  stdin.transform(Utf8Decoder()).listen((line) => wrapParseInput(line.trim()),
      onError: (Object err) => print('error: $err'));
}

/// Error handling.
void wrapParseInput(String input) {
  try {
    parseInput(input);
  } catch (e) {
    print('! ERROR: $e');
  }
}

/// Parses the input and invokes appropriate methods.
void parseInput(String input) {
  /// Evaluate with ?
  if (input == '?') {
    return _evaluate();
  }

  /// Set variable with x=1
  if (input.contains('=')) {
    return _setVar(input);
  }

  /// Get variable with ?x
  if (input.startsWith('?')) {
    return _getVar(input);
  }

  /// Differentiate expression in respect to variable with !x
  if (input.startsWith('!')) {
    return _differentiate(input);
  }

  /// Set current expression.
  _setExpr(input);
}

void _evaluate() {
  if (currentExpression == null) throw StateError('No Expression set.');
  double eval = currentExpression!.evaluate(EvaluationType.REAL, contextModel);
  print('> Variables: ${contextModel.variables}');
  print('> Result: $currentExpression = ${eval.toString()}');
}

void _setExpr(String input) {
  var tokens = lexer.tokenize(input);
  var rpn = lexer.tokenizeToRPN(input);
  var expr = parser.parse(input);
  print('> Tokens: $tokens');
  print('> RPN: $rpn');
  print('> Expression: $expr');

  currentExpression = expr;
}

void _differentiate(String input) {
  if (currentExpression == null) throw StateError('No Expression set.');
  String varName = input.substring(1);
  Expression expr = currentExpression!.derive(varName);

  /// cheap attempt to simplify new expression as much as possible
  while (expr.toString() != expr.simplify().toString()) {
    expr = expr.simplify();
  }
  print('> Partial derivative of f = $currentExpression:');
  print('> ∂f/∂$varName = f\' = ${expr.toString()}');
}

void _setVar(String input) {
  String varName = input.split('=')[0].trim();
  String expression = input.split('=')[1].trim();
  var expr = parser.parse(expression);
  contextModel.bindVariableName(varName, expr);
  print('> Bound variable $varName to $expr.');
}

void _getVar(String input) {
  String varName = input.substring(1);
  var expr = contextModel.getExpression(varName);
  print('> $varName is bound to $expr.');
}
