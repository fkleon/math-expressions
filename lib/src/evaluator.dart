part of '../math_expressions.dart';

/// Mathematical expressions must be evaluated under a certain [EvaluationType].
///
/// Currently there are three types, but not all expressions support each type.
/// If you try to evaluate an expression with an unsupported type, it will raise
/// an [UnimplementedError] or [UnsupportedError].
///
/// - REAL
/// - VECTOR
/// - INTERVAL
///
enum EvaluationType { REAL, VECTOR, INTERVAL }

/// The context model keeps track of all known variables and functions.
///
/// It is structured hierarchically to offer nested scopes.
class ContextModel {
  /// The parent scope.
  final ContextModel? parentScope;

  /// Variable map of this scope (name -> expression).
  final Map<String, Expression> variables = <String, Expression>{};

  /// Function set of this scope.
  // TODO: Do we even need to track function names?
  final Set<MathFunction> functions = <MathFunction>{};

  /// Creates a new, empty root context model.
  ContextModel() : parentScope = null;

  /// Internal constructor for creating a child scope.
  ContextModel._child(this.parentScope);

  /// Returns a new child scope of this scope.
  ContextModel createChildScope() => ContextModel._child(this);

  /// Returns the bound expression for the given variable.
  /// Performs recursive lookup through `parentScope`.
  ///
  /// Throws a [StateError], if variable is still unbound at the root scope.
  Expression getExpression(String varName) {
    if (variables.containsKey(varName)) {
      return variables[varName]!;
    }

    if (parentScope != null) {
      return parentScope!.getExpression(varName);
    } else {
      throw StateError('Variable not bound: $varName');
    }
  }

  /// Returns the function for the given function name.
  /// Performs recursive lookup through `parentScope`.
  ///
  /// Throws a [StateError], if function is still unbound at the root scope.
  MathFunction getFunction(String name) {
    final Iterable<MathFunction> candidates =
        functions.where((mathFunction) => mathFunction.name == name);
    if (candidates.isNotEmpty) {
      // just grab first - should not contain doubles.
      return candidates.first;
    } else if (parentScope != null) {
      return parentScope!.getFunction(name);
    } else {
      throw StateError('Function not bound: $name');
    }
  }

  /// Binds a variable to an expression in this context.
  void bindVariable(Variable v, Expression e) {
    variables[v.name] = e;
  }

  /// Binds a variable name to an expression in this context.
  void bindVariableName(String vName, Expression e) {
    variables[vName] = e;
  }

  /// Unbinds a variable name in this context
  void unbindVariableName(String vName) {
    variables.remove(vName);
  }

  /// Binds a function to this context.
  void bindFunction(MathFunction f) {
    //TODO force non-duplicates.
    functions.add(f);
  }

  @override
  String toString() => 'ContextModel['
      'PARENT: $parentScope, '
      'VARS: ${variables.toString()}, '
      'FUNCS: ${functions.toString()}]';
}

/// An expression visitor that collects all variables in an expression.
class VariableCollector extends NullExpressionVisitor {
  final Set<String> _variables = {};

  /// Evaluate the given expression.
  ///
  /// Returns the distinct variable names found in the given expression.
  Iterable<String> evaluate(Expression exp) {
    assert(_variables.isEmpty);

    try {
      exp.accept(this);
      return {..._variables};
    } finally {
      _variables.clear();
    }
  }

  @override
  void visitVariable(Variable literal) {
    this._variables.add(literal.name);
  }
}
