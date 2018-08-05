import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:math_expressions/math_expressions.dart';

ContextModel _contextModel = new ContextModel();
Expression _lastExpression;

/**
 * Starts a CLI interpreter.
 */
void main() {
  print('Please, enter any expression. \n');
  print('The following commands are also supported:');
  print('? (evaluates the current expression)');
  print('<var>=<expr> (bind variable <var> to expression)');
  print('?<var> (get variable binding) \n');

  Stream cmdLine = stdin.transform(new Utf8Decoder());

  cmdLine.listen(
      (line) => wrapParseInput(line.trim()),
      onError: (err) => print("error: $err"));
}

/// Error handling.
void wrapParseInput(String input) {
  try {
    parseInput(input);
  } catch(e) {
    print('ERROR: $e');
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
  
  /// Set current expression.
  _setExpr(input);
}

void _evaluate() {
  if (_lastExpression == null) throw new StateError('No Expression set.');
  double eval = _lastExpression.evaluate(EvaluationType.REAL, _contextModel);
  print('Variables: ${_contextModel.variables}');
  print('Result: $_lastExpression = ${eval.toString()}');
}

void _setExpr(String input) {
  var tokens = new Lexer().tokenize(input);
  var rpn = new Lexer().tokenizeToRPN(input);
  var expr = new Parser().parse(input);
  print('Tokens: $tokens');
  print('RPN: $rpn');
  print('Expression: $expr');

  _lastExpression = expr;
}

void _setVar(String input) {
  String varName = input.split('=')[0].trim();
  String expression = input.split('=')[1].trim();
  var expr = new Parser().parse(expression);
  _contextModel.bindVariableName(varName, expr);
  print('Bound variable $varName to $expr.');
}

void _getVar(input) {
  String varName = input.substring(1);
  var expr = _contextModel.getExpression(varName);
  print('$varName is bound to $expr.');
}