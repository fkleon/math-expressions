import 'package:math_expressions/math_expressions.dart';
import 'package:source_span/source_span.dart';
import 'package:tuple/tuple.dart';

Expression parseString(String source,
    {Map<String, Function> handlers = const {}}) {
  final state = State(source);
  state.context = _Context(handlers: handlers);
  final result = _parse(state);
  if (!state.ok) {
    final message = _errorMessage(source, state.errors);
    throw FormatException('\n$message');
  }

  return result!;
}

Expression? parse(State<String> state,
    {Map<String, Function> handlers = const {}}) {
  return _parse(state);
}

void _ws(State<String> state) {
  final source = state.source;
  while (state.pos < source.length) {
    final c = source.codeUnitAt(state.pos);
    final ok = c <= 32 && (c >= 9 && c <= 10 || c == 13 || c == 32);
    if (!ok) {
      break;
    }
    state.pos++;
  }
  state.ok = true;
}

void _eof(State<String> state) {
  final source = state.source;
  state.ok = state.pos >= source.length;
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, 'EOF');
  }
}

Expression? _parse(State<String> state) {
  Expression? $0;
  final $pos = state.pos;
  _ws(state);
  if (state.ok) {
    $0 = _expression(state);
    if (state.ok) {
      _eof(state);
    }
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

String? _unaryOperator(State<String> state) {
  String? $0;
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    if (c == 45) {
      state.pos++;
      v = '-';
    } else if (c == 8722) {
      state.pos++;
      v = '−';
    } else if (c == 8730) {
      state.pos++;
      v = '√';
    } else if (c == 8731) {
      state.pos++;
      v = '∛';
    } else if (c == 8732) {
      state.pos++;
      v = '∜';
    }
    state.ok = v != null;
    if (state.ok) {
      $0 = v;
    }
  }
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, '-');
    state.fail(state.pos, ParseError.expected, 0, '−');
    state.fail(state.pos, ParseError.expected, 0, '√');
    state.fail(state.pos, ParseError.expected, 0, '∛');
    state.fail(state.pos, ParseError.expected, 0, '∜');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

void _digit1(State<String> state) {
  final source = state.source;
  final $pos = state.pos;
  while (state.pos < source.length) {
    final c = source.codeUnitAt(state.pos);
    final ok = c >= 48 && c <= 57;
    if (!ok) {
      break;
    }
    state.pos++;
  }
  state.ok = state.pos != $pos;
  if (!state.ok) {
    state.fail($pos, ParseError.character, 0, 0);
  }
}

Expression? _integer(State<String> state) {
  Expression? $0;
  final source = state.source;
  final $log = state.log;
  state.log = false;
  Expression? $1;
  String? $2;
  final $pos = state.pos;
  final $memo = state.memoized<String?>(0, false, state.pos);
  if ($memo != null) {
    $memo.restore(state);
  } else {
    final $pos1 = state.pos;
    _digit1(state);
    state.memoize<String?>(0, true, $pos1);
  }
  if (state.ok) {
    $2 = source.slice($pos, state.pos);
  }
  if (state.ok) {
    final v = $2!;
    $1 = Number(int.parse(v));
  }
  state.log = $log;
  if (state.ok) {
    $0 = $1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'integer');
  }
  return $0;
}

Expression? _numberImpl(State<String> state) {
  Expression? $0;
  final source = state.source;
  final $min = state.minErrorPos;
  state.minErrorPos = state.pos + 1;
  Expression? $1;
  String? $2;
  final $pos = state.pos;
  final $pos1 = state.pos;
  final $memo = state.memoized<String?>(0, false, state.pos);
  if ($memo != null) {
    $memo.restore(state);
  } else {
    final $pos2 = state.pos;
    _digit1(state);
    state.memoize<String?>(0, true, $pos2);
  }
  if (state.ok) {
    final $log = state.log;
    state.log = false;
    state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 46;
    if (state.ok) {
      state.pos += 1;
    } else {
      state.fail(state.pos, ParseError.expected, 0, '.');
    }
    state.log = $log;
    if (state.ok) {
      _digit1(state);
      if (state.ok) {
        //
      }
    }
  }
  if (!state.ok) {
    state.pos = $pos1;
  }
  if (state.ok) {
    $2 = source.slice($pos, state.pos);
  }
  if (state.ok) {
    final v = $2!;
    $1 = Number(num.parse(v));
  }
  state.minErrorPos = $min;
  if (state.ok) {
    $0 = $1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'decimal number');
  }
  if (!state.ok) {
    $0 = _integer(state);
  }
  return $0;
}

Expression? _number(State<String> state) {
  Expression? $0;
  final $min = state.minErrorPos;
  state.minErrorPos = state.pos + 1;
  Expression? $1;
  $1 = _numberImpl(state);
  state.minErrorPos = $min;
  if (state.ok) {
    $0 = $1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'number');
  }
  return $0;
}

Expression? _exponentialOperator(State<String> state) {
  Expression? $0;
  final source = state.source;
  final $pos = state.pos;
  final $pos1 = state.pos;
  state.ok = state.pos + 1 < source.length &&
      source.codeUnitAt(state.pos) == 101 &&
      source.codeUnitAt(state.pos + 1) == 94;
  if (state.ok) {
    state.pos += 2;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'e^');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    state.pos = $pos1;
  }
  if (state.ok) {
    Expression? $1;
    $1 = _number(state);
    if (state.ok) {
      final v1 = $1!;
      $0 = Exponential(v1);
    }
  }
  if (!state.ok) {
    state.pos = $pos;
  }
  return $0;
}

void _openParen(State<String> state) {
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 40;
  if (state.ok) {
    state.pos += 1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, '(');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    state.pos = $pos;
  }
}

void _comma(State<String> state) {
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 44;
  if (state.ok) {
    state.pos += 1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, ',');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    state.pos = $pos;
  }
}

List<Expression>? _argumentList(State<String> state) {
  List<Expression>? $0;
  var $pos = state.pos;
  final $list = <Expression>[];
  while (true) {
    Expression? $1;
    $1 = _expression(state);
    if (!state.ok) {
      state.pos = $pos;
      break;
    }
    $list.add($1!);
    $pos = state.pos;
    final $log = state.log;
    state.log = false;
    _comma(state);
    state.log = $log;
    if (!state.ok) {
      break;
    }
  }
  state.ok = true;
  if (state.ok) {
    $0 = $list;
  }
  return $0;
}

void _closeParen(State<String> state) {
  final source = state.source;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 41;
  if (state.ok) {
    state.pos += 1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, ')');
  }
}

List<Expression>? _arguments(State<String> state) {
  List<Expression>? $0;
  final $min = state.minErrorPos;
  state.minErrorPos = state.pos + 1;
  List<Expression>? $1;
  final $pos = state.pos;
  _openParen(state);
  if (state.ok) {
    $1 = _argumentList(state);
    if (state.ok) {
      _closeParen(state);
    }
  }
  if (!state.ok) {
    $1 = null;
    state.pos = $pos;
  }
  state.minErrorPos = $min;
  if (state.ok) {
    $0 = $1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'function arguments');
  }
  return $0;
}

Expression? _exponentialFunction(State<String> state) {
  Expression? $0;
  final source = state.source;
  Tuple2<String, List<Expression>>? $1;
  final $pos = state.pos;
  Tuple2<String, List<Expression>>? $2;
  final $pos1 = state.pos;
  String? $3;
  final $pos2 = state.pos;
  state.ok = state.pos + 1 < source.length &&
      source.codeUnitAt(state.pos) == 101 &&
      source.codeUnitAt(state.pos + 1) == 94;
  if (state.ok) {
    state.pos += 2;
    $3 = 'e^';
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'e^');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $3 = null;
    state.pos = $pos2;
  }
  if (state.ok) {
    List<Expression>? $4;
    $4 = _arguments(state);
    if (state.ok) {
      $2 = Tuple2($3!, $4!);
    }
  }
  if (!state.ok) {
    state.pos = $pos1;
  }
  if (state.ok) {
    final v = $2!;
    state.ok = _verifyArguments(v);
    if (state.ok) {
      $1 = v;
    } else {
      final length = $pos - state.pos;
      state.fail(state.pos, ParseError.message, length,
          'Wrong number or types of arguments');
      state.pos = $pos;
    }
  }
  if (state.ok) {
    final v = $1!;
    $0 = _toFunction(state, v);
  }
  return $0;
}

Expression? _exponentialExpression(State<String> state) {
  Expression? $0;
  $0 = _exponentialOperator(state);
  if (!state.ok) {
    $0 = _exponentialFunction(state);
  }
  return $0;
}

Expression? _constantPi(State<String> state) {
  Expression? $0;
  final source = state.source;
  String? $1;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 960;
  if (state.ok) {
    state.pos += 1;
    $1 = 'π';
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'π');
  }
  if (state.ok) {
    final v = $1!;
    $0 = Number(3.141592653589793);
  }
  return $0;
}

Expression? _constantInfinity(State<String> state) {
  Expression? $0;
  final source = state.source;
  String? $1;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 8734;
  if (state.ok) {
    state.pos += 1;
    $1 = '∞';
  } else {
    state.fail(state.pos, ParseError.expected, 0, '∞');
  }
  if (state.ok) {
    final v = $1!;
    $0 = Number(double.infinity);
  }
  return $0;
}

Expression? _constantNegativeInfinity(State<String> state) {
  Expression? $0;
  final source = state.source;
  String? $1;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    if (c == 45) {
      if (source.startsWith('-∞', pos)) {
        state.pos += 2;
        v = '-∞';
      }
    } else if (c == 8722) {
      if (source.startsWith('−∞', pos)) {
        state.pos += 2;
        v = '−∞';
      }
    }
    state.ok = v != null;
    if (state.ok) {
      $1 = v;
    }
  }
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, '-∞');
    state.fail(state.pos, ParseError.expected, 0, '−∞');
  }
  if (state.ok) {
    final v = $1!;
    $0 = Number(double.negativeInfinity);
  }
  return $0;
}

Expression? _constantExpression(State<String> state) {
  Expression? $0;
  $0 = _constantPi(state);
  if (!state.ok) {
    $0 = _constantInfinity(state);
    if (!state.ok) {
      $0 = _constantNegativeInfinity(state);
    }
  }
  return $0;
}

String? _identifier(State<String> state) {
  String? $0;
  final source = state.source;
  final $pos = state.pos;
  final $pos1 = state.pos;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final c = source.codeUnitAt(state.pos++);
    state.ok = c <= 122 && (c >= 65 && c <= 90 || c >= 97 && c <= 122);
    if (state.ok) {
      while (state.pos < source.length) {
        final pos = state.pos;
        final c = source.codeUnitAt(state.pos++);
        state.ok = c <= 122 &&
            (c >= 48 && c <= 57 ||
                c >= 65 && c <= 90 ||
                c == 95 ||
                c >= 97 && c <= 122);
        if (!state.ok) {
          state.pos = pos;
          break;
        }
      }
      state.ok = true;
      final text = source.slice($pos1, state.pos);
      final length = text.length;
      final c = text.codeUnitAt(0);
      final words = const <List<String>>[];
      var index = -1;
      var min = 0;
      var max = words.length - 1;
      while (min <= max) {
        final mid = min + (max - min) ~/ 2;
        final x = words[mid][0].codeUnitAt(0);
        if (x == c) {
          index = mid;
          break;
        }
        if (x < c) {
          min = mid + 1;
        } else {
          max = mid - 1;
        }
      }
      if (index != -1) {
        final list = words[index];
        for (var i = list.length - 1; i >= 0; i--) {
          final v = list[i];
          if (length > v.length) {
            break;
          }
          if (length == v.length && text == v) {
            state.ok = false;
            break;
          }
        }
      }
      if (state.ok) {
        $0 = text;
      }
    }
  }
  if (!state.ok) {
    state.pos = $pos1;
    state.fail(state.pos, ParseError.expected, 0, 'identifier');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

Expression? _functionInvocation(State<String> state) {
  Expression? $0;
  Tuple2<String, List<Expression>>? $1;
  final $pos = state.pos;
  Tuple2<String, List<Expression>>? $2;
  final $pos1 = state.pos;
  String? $3;
  final $memo = state.memoized<String?>(1, false, state.pos);
  if ($memo != null) {
    $3 = $memo.restore(state);
  } else {
    final $pos2 = state.pos;
    $3 = _identifier(state);
    state.memoize<String?>(1, false, $pos2, $3);
  }
  if (state.ok) {
    List<Expression>? $4;
    $4 = _arguments(state);
    if (state.ok) {
      $2 = Tuple2($3!, $4!);
    }
  }
  if (!state.ok) {
    state.pos = $pos1;
  }
  if (state.ok) {
    final v = $2!;
    state.ok = _verifyArguments(v);
    if (state.ok) {
      $1 = v;
    } else {
      final length = $pos - state.pos;
      state.fail(state.pos, ParseError.message, length,
          'Wrong number or types of arguments');
      state.pos = $pos;
    }
  }
  if (state.ok) {
    final v = $1!;
    $0 = _toFunction(state, v);
  }
  return $0;
}

Expression? _variable(State<String> state) {
  Expression? $0;
  String? $1;
  final $memo = state.memoized<String?>(1, false, state.pos);
  if ($memo != null) {
    $1 = $memo.restore(state);
  } else {
    final $pos = state.pos;
    $1 = _identifier(state);
    state.memoize<String?>(1, false, $pos, $1);
  }
  if (state.ok) {
    final v = $1!;
    $0 = Variable(v);
  }
  return $0;
}

Expression? _primaryExpression(State<String> state) {
  Expression? $0;
  final $pos = state.pos;
  final $min = state.minErrorPos;
  state.minErrorPos = state.pos + 1;
  Expression? $1;
  $1 = _exponentialExpression(state);
  if (!state.ok) {
    $1 = _constantExpression(state);
    if (!state.ok) {
      $1 = _functionInvocation(state);
      if (!state.ok) {
        $1 = _variable(state);
        if (!state.ok) {
          $1 = _number(state);
          if (!state.ok) {
            final $pos1 = state.pos;
            _openParen(state);
            if (state.ok) {
              $1 = _expression(state);
              if (state.ok) {
                _closeParen(state);
              }
            }
            if (!state.ok) {
              $1 = null;
              state.pos = $pos1;
            }
          }
        }
      }
    }
  }
  state.minErrorPos = $min;
  if (state.ok) {
    $0 = $1;
  } else {
    state.fail(state.pos, ParseError.expected, 0, 'expression');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

Expression? _unaryExpression(State<String> state) {
  Expression? $0;
  final $pos = state.pos;
  String? $1;
  final $log = state.log;
  state.log = false;
  $1 = _unaryOperator(state);
  state.log = $log;
  final $ok = state.ok;
  Expression? $2;
  $2 = _primaryExpression(state);
  if (state.ok) {
    if ($ok) {
      final v1 = $1!;
      final v2 = $2!;
      $0 = _toUnary(v1, v2);
    } else {
      $0 = $2!;
    }
  } else {
    state.pos = $pos;
  }
  return $0;
}

String? _postfixOperator(State<String> state) {
  String? $0;
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    if (c == 33) {
      state.pos++;
      v = '!';
    } else if (c == 176) {
      state.pos++;
      v = '°';
    }
    state.ok = v != null;
    if (state.ok) {
      $0 = v;
    }
  }
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, '!');
    state.fail(state.pos, ParseError.expected, 0, '°');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

Expression? _postfixExpression(State<String> state) {
  Expression? $0;
  Expression? $1;
  $1 = _unaryExpression(state);
  if (state.ok) {
    String? $2;
    final $log = state.log;
    state.log = false;
    $2 = _postfixOperator(state);
    state.log = $log;
    if (state.ok) {
      final v1 = $1!;
      final v2 = $2!;
      $0 = _toPostfix(v1, v2);
    } else {
      state.ok = true;
      $0 = $1!;
    }
  }
  return $0;
}

String? _multiplicativeOperator(State<String> state) {
  String? $0;
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    if (c == 42) {
      state.pos++;
      v = '*';
    } else if (c == 215) {
      state.pos++;
      v = '×';
    } else if (c == 47) {
      state.pos++;
      v = '/';
    } else if (c == 247) {
      state.pos++;
      v = '÷';
    } else if (c == 37) {
      state.pos++;
      v = '%';
    } else if (c == 94) {
      state.pos++;
      v = '^';
    }
    state.ok = v != null;
    if (state.ok) {
      $0 = v;
    }
  }
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, '*');
    state.fail(state.pos, ParseError.expected, 0, '×');
    state.fail(state.pos, ParseError.expected, 0, '/');
    state.fail(state.pos, ParseError.expected, 0, '÷');
    state.fail(state.pos, ParseError.expected, 0, '%');
    state.fail(state.pos, ParseError.expected, 0, '^');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

Expression? _multiplicative(State<String> state) {
  Expression? $0;
  final $pos = state.pos;
  Expression? $left;
  Expression? $1;
  $1 = _postfixExpression(state);
  if (state.ok) {
    $left = $1;
    while (true) {
      String? $2;
      final $log = state.log;
      state.log = false;
      $2 = _multiplicativeOperator(state);
      state.log = $log;
      if (!state.ok) {
        state.ok = true;
        break;
      }
      Expression? $3;
      $3 = _postfixExpression(state);
      if (!state.ok) {
        state.pos = $pos;
        break;
      }
      final $op = $2!;
      final $right = $3!;
      $left = _toBinary($left!, $op, $right);
    }
  }
  if (state.ok) {
    $0 = $left;
  }
  return $0;
}

String? _additiveOperator(State<String> state) {
  String? $0;
  final source = state.source;
  final $pos = state.pos;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    if (c == 43) {
      state.pos++;
      v = '+';
    } else if (c == 45) {
      state.pos++;
      v = '-';
    } else if (c == 8722) {
      state.pos++;
      v = '−';
    }
    state.ok = v != null;
    if (state.ok) {
      $0 = v;
    }
  }
  if (!state.ok) {
    state.fail(state.pos, ParseError.expected, 0, '+');
    state.fail(state.pos, ParseError.expected, 0, '-');
    state.fail(state.pos, ParseError.expected, 0, '−');
  }
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

Expression? _additive(State<String> state) {
  Expression? $0;
  final $pos = state.pos;
  Expression? $left;
  Expression? $1;
  $1 = _multiplicative(state);
  if (state.ok) {
    $left = $1;
    while (true) {
      String? $2;
      final $log = state.log;
      state.log = false;
      $2 = _additiveOperator(state);
      state.log = $log;
      if (!state.ok) {
        state.ok = true;
        break;
      }
      Expression? $3;
      $3 = _multiplicative(state);
      if (!state.ok) {
        state.pos = $pos;
        break;
      }
      final $op = $2!;
      final $right = $3!;
      $left = _toBinary($left!, $op, $right);
    }
  }
  if (state.ok) {
    $0 = $left;
  }
  return $0;
}

Expression? _expression(State<String> state) {
  Expression? $0;
  $0 = _additive(state);
  return $0;
}

String _errorMessage(String source, List<ParseError> errors,
    [Object? color, int maxCount = 10, String? url]) {
  final sb = StringBuffer();
  for (var i = 0; i < errors.length; i++) {
    if (i > maxCount) {
      break;
    }

    final error = errors[i];
    final start = error.start;
    final end = error.end + 1;
    if (end > source.length) {
      source += ' ' * (end - source.length);
    }

    final file = SourceFile.fromString(source, url: url);
    final span = file.span(start, end);
    if (sb.isNotEmpty) {
      sb.writeln();
    }

    sb.write(span.message(error.toString(), color: color));
  }

  if (errors.length > maxCount) {
    sb.writeln();
    sb.write('(${errors.length - maxCount} more errors...)');
  }

  return sb.toString();
}

class ParseError {
  static const character = 0;

  static const expected = 1;

  static const message = 2;

  static const unexpected = 3;

  final int end;

  final int start;

  final String text;

  ParseError(this.start, this.end, this.text);

  @override
  int get hashCode => end.hashCode ^ start.hashCode ^ text.hashCode;

  @override
  bool operator ==(other) =>
      other is ParseError &&
      other.end == end &&
      other.start == start &&
      other.text == text;

  @override
  String toString() {
    return text;
  }
}

class State<T> {
  dynamic context;

  int errorPos = -1;

  int lastErrorPos = -1;

  int minErrorPos = -1;

  bool log = true;

  bool ok = false;

  int pos = 0;

  final T source;

  final List<int> _kinds = List.filled(150, 0);

  int _length = 0;

  final List<int> _lengths = List.filled(150, 0);

  final List<_Memo?> _memos = List.filled(150, null);

  final List<Object?> _values = List.filled(150, null);

  State(this.source);

  List<ParseError> get errors => _buildErrors();

  @pragma('vm:prefer-inline')
  void fail(int pos, int kind, int length, Object? value) {
    if (log) {
      if (errorPos <= pos && minErrorPos <= pos) {
        if (errorPos < pos) {
          errorPos = pos;
          _length = 0;
        }

        _kinds[_length] = kind;
        _lengths[_length] = length;
        _values[_length] = value;
        _length++;
      }

      if (lastErrorPos < pos) {
        lastErrorPos = pos;
      }
    }
  }

  @pragma('vm:prefer-inline')
  void memoize<R>(int id, bool fast, int start, [R? result]) =>
      _memos[id] = _Memo<R>(id, fast, start, pos, ok, result);

  @pragma('vm:prefer-inline')
  _Memo<R>? memoized<R>(int id, bool fast, int start) {
    final memo = _memos[id];
    return (memo != null &&
            memo.start == start &&
            (memo.fast == fast || !memo.fast))
        ? memo as _Memo<R>
        : null;
  }

  @pragma('vm:prefer-inline')
  void restoreLastErrorPos(int pos) {
    if (lastErrorPos < pos) {
      lastErrorPos = pos;
    }
  }

  @pragma('vm:prefer-inline')
  int setLastErrorPos(int pos) {
    final result = lastErrorPos;
    lastErrorPos = pos;
    return result;
  }

  @override
  String toString() {
    if (source is String) {
      final s = source as String;
      if (pos >= s.length) {
        return '$pos:';
      }

      var length = s.length - pos;
      length = length > 40 ? 40 : length;
      final string = s.substring(pos, pos + length);
      return '$pos:$string';
    } else {
      return super.toString();
    }
  }

  List<ParseError> _buildErrors() {
    final result = <ParseError>[];
    final expected = <String>[];
    for (var i = 0; i < _length; i++) {
      final kind = _kinds[i];
      if (kind == ParseError.expected) {
        var value = _values[i];
        final escaped = _escape(value);
        expected.add(escaped);
      }
    }

    if (expected.isNotEmpty) {
      final text = 'Expected: ${expected.toSet().join(', ')}';
      final error = ParseError(errorPos, errorPos, text);
      result.add(error);
    }

    for (var i = 0; i < _length; i++) {
      final kind = _kinds[i];
      var length = _lengths[i];
      var value = _values[i];
      var start = errorPos;
      final sign = length >= 0 ? 1 : -1;
      length = length * sign;
      if (sign == -1) {
        start = start - length;
      }

      final end = start + (length > 0 ? length - 1 : 0);
      switch (kind) {
        case ParseError.character:
          if (source is String) {
            final string = source as String;
            if (start < string.length) {
              value = string.runeAt(errorPos);
              final escaped = _escape(value);
              final error =
                  ParseError(errorPos, errorPos, 'Unexpected $escaped');
              result.add(error);
            } else {
              final error = ParseError(errorPos, errorPos, "Unexpected 'EOF'");
              result.add(error);
            }
          } else {
            final error =
                ParseError(errorPos, errorPos, 'Unexpected character');
            result.add(error);
          }

          break;
        case ParseError.expected:
          break;
        case ParseError.message:
          final error = ParseError(start, end, '$value');
          result.add(error);
          break;
        case ParseError.unexpected:
          final escaped = _escape(value);
          final error = ParseError(start, end, 'Unexpected $escaped');
          result.add(error);
          break;
        default:
          final error = ParseError(start, end, '$value');
          result.add(error);
      }
    }

    return result.toSet().toList();
  }

  String _escape(Object? value, [bool quote = true]) {
    if (value is int) {
      if (value >= 0 && value <= 0xd7ff ||
          value >= 0xe000 && value <= 0x10ffff) {
        value = String.fromCharCode(value);
      } else {
        return value.toString();
      }
    } else if (value is! String) {
      return value.toString();
    }

    final map = {
      '\b': '\\b',
      '\f': '\\f',
      '\n': '\\n',
      '\r': '\\r',
      '\t': '\\t',
      '\v': '\\v',
    };
    var result = value.toString();
    for (final key in map.keys) {
      result = result.replaceAll(key, map[key]!);
    }

    if (quote) {
      result = "'$result'";
    }

    return result;
  }
}

extension on String {
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int readRune(State<String> state) {
    final w1 = codeUnitAt(state.pos++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (state.pos < length) {
        final w2 = codeUnitAt(state.pos++);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }

        state.pos--;
      }

      throw FormatException('Invalid UTF-16 character', this, state.pos - 1);
    }

    return w1;
  }

  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }

      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }

    return w1;
  }

  /// Returns a slice (substring) of the string from [start] to [end].
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  String slice(int start, int end) {
    return substring(start, end);
  }
}

class _Memo<T> {
  final int end;

  final bool fast;

  final int id;

  final bool ok;

  final T? result;

  final int start;

  _Memo(this.id, this.fast, this.start, this.end, this.ok, this.result);

  @pragma('vm:prefer-inline')
  T? restore(State state) {
    state.ok = ok;
    state.pos = end;
    return result;
  }
}

Expression _toBinary(Expression left, String op, Expression right) {
  switch (op) {
    case '+':
      return left + right;
    case '-':
    case '−':
      return left - right;
    case '*':
    case '×':
      return left * right;
    case '/':
    case '÷':
      return left / right;
    case '%':
      return left % right;
    case '^':
      return left ^ right;
    default:
      throw "Unsupported binary operation '$op'";
  }
}

Expression _toFunction(
    State<String> state, Tuple2<String, List<Expression>> declaration) {
  final name = declaration.item1;
  final arguments = declaration.item2;
  Expression func(bool condition, Expression Function() f) {
    if (condition) {
      return f();
    } else {
      throw StateError('Invalid number of arguments or their type: $name');
    }
  }

  final length = arguments.length;
  switch (name) {
    case 'abs':
      return func(length == 1, () => Abs(arguments[0]));
    case 'arccos':
      return func(length == 1, () => Acos(arguments[0]));
    case 'arcsin':
      return func(length == 1, () => Asin(arguments[0]));
    case 'arctan':
      return func(length == 1, () => Atan(arguments[0]));
    case 'ceil':
      return func(length == 1, () => Ceil(arguments[0]));
    case 'cos':
      return func(length == 1, () => Cos(arguments[0]));
    case 'e^':
      return func(length == 1, () => Exponential(arguments[0]));
    case 'floor':
      return func(length == 1, () => Floor(arguments[0]));
    case 'ln':
      return func(length == 1, () => Ln(arguments[0]));
    case 'log':
      return func(length == 2, () => Log(arguments[0], arguments[1]));
    case 'nrt':
      return func(length == 2 && arguments[0] is Number,
          () => Root.fromExpr(arguments[0] as Number, arguments[1]));
    case 'sgn':
      return func(length == 1, () => Sgn(arguments[0]));
    case 'sin':
      return func(length == 1, () => Sin(arguments[0]));
    case 'sqrt':
      return func(length == 1, () => Sqrt(arguments[0]));
    case 'tan':
      return func(length == 1, () => Tan(arguments[0]));
    default:
      final context = state.context as _Context;
      final handlers = context.handlers;
      var handler = handlers[name];
      handler ??= (List arguments) =>
          throw StateError('Function Handler not found: $name');
      return AlgorithmicFunction(name, arguments, handler);
  }
}

Expression _toPostfix(Expression expression, String operand) {
  switch (operand) {
    case '!':
      return Factorial(expression);
    case '°':
      if (expression is Number) {
        return Number((expression.value as num) * 3.141592653589793 / 180);
      } else {
        return expression * Number(3.141592653589793 / 180);
      }
  }
  throw StateError('Unknown postfix operator: $operand');
}

Expression _toUnary(String operand, Expression expression) {
  switch (operand) {
    case '-':
      return -expression;
    case '−':
      return -expression;
    case '√':
      return Sqrt(expression);
    case '∛':
      return Root.fromExpr(Number(3), expression);
    case '∜':
      return Root.fromExpr(Number(4), expression);
  }
  throw StateError('Unknown unary operator: $operand');
}

bool _verifyArguments(Tuple2<String, List<Expression>> declaration) {
  final name = declaration.item1;
  final arguments = declaration.item2;
  switch (name) {
    case 'abs':
    case 'arccos':
    case 'arcsin':
    case 'arctan':
    case 'ceil':
    case 'cos':
    case 'e^':
    case 'floor':
    case 'ln':
    case 'sgn':
    case 'sin':
    case 'sqrt':
    case 'tan':
      return arguments.length == 1;
    case 'log':
      return arguments.length == 2;
    case 'nrt':
      return arguments.length == 2 && arguments[0] is Number;
    default:
      return true;
  }
}

class _Context {
  final Map<String, Function> handlers;

  _Context({required this.handlers});
}
