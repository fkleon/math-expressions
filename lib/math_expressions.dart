/*
 * math_expressions
 *
 * Copyright (c) 2013-2019  Frederik Leonhardt <frederik.leonhardt@gmail.com>,
 *                          Michael Frey <asakash117@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/// A math library for parsing and evaluating expressions in real, interval and
/// vector contexts. It also supports simplification and differentiation of
/// expressions.
///
/// The libary supports the three basic data types [Number], [Interval] and
/// [Vector]. It includes the [GrammarParser] to create [Expression]s from
/// string inputs.
///
/// For backwards-compatibility the legacy [ShuntingYardParser] is also
/// included. Users are encouraged to switch to [GrammarParser] as it will
/// not receive new features and bug fixes.
library;

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2, Vector3, Vector4;
import 'package:petitparser/petitparser.dart' hide Parser;
import 'package:petitparser/petitparser.dart' as pp show Parser;

part 'src/algebra.dart';
part 'src/ast.dart';
part 'src/evaluator.dart';
part 'src/expression.dart';
part 'src/functions.dart';
part 'src/parser.dart';
part 'src/parser_petit.dart';
