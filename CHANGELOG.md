# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.7.0-rc.2]

### Added

- Add support for n-th root function to `GrammarParser`.

### Fixed

- Tighten dependency constraints to fix issue with lower bounds dependencies.

## [2.7.0-rc.1] - 2025-02-01

### Added

- Add a modern grammar-based expression parser. This is opt-in at this stage,
  and can be used by instantiating a `GrammarParser` instead of the legacy
  `Parser`.
  The new parser fixes some long-standing issues with expression parsing, but
  is still missing a few features that were previously supported by the legacy
  parser:
  - Implicit multiplication is not supported yet.
  - Parsing of the n-th root function is not supported yet.
- Add support for parsing constants, with initial support for `pi`and `e`
  (Euler's constant). #26

### Deprecated

- Renamed the existing expression parser to `ShuntingYardParser`. This parser
  is now in maintenance mode and will not receive any new features.
  `Parser` remains as a deprecated type alias to this legacy implemenation to
  maintain backwards compatibility.

### Fixed

- Exception when define variable Number with character "e" #82
- Suppress conversion into e function #61
- Variables should resolve before keywords. #31

## [2.6.0] - 2024-07-31

### Added

- Add parser support for implicit multiplication (thanks [juca1331](https://github.com/juca1331))

### Changed

- Drop support for Dart SDK versions below 3.1.0

## [2.5.0] - 2024-04-16

### Added

- Add support for parsing variables containing digits (thanks [alexander-zubkov](https://github.com/alexander-zubkov))

### Changed

- Rewrite expression parser to use a grammar-based parsing (with petitparser).
- Drop support for Dart SDK versions below 3.0.0
- Refactor unit test suites and improve test coverage
- Switch from pedantic to the [official Dart lint rules](https://pub.dev/packages/lints)

## [2.4.0] - 2023-04-05

### Added

- Add UnaryPlus operator (thanks [jpnurmi](https://github.com/jpnurmi))

### Changed

- Improve evaluation of unary minus as an exponent of a power (thanks [edhom](https://github.com/edhom))
- Use markdown LaTeX instead of images in README (thanks [dvirberlo](https://github.com/dvirberlo))

## [2.3.1] - 2022-05-30

### Changed

- Evaluate roots written as powers correctly for negative bases (thanks [edhom](https://github.com/edhom))

## [2.3.0] - 2021-12-21

### Added

- Add factorial function (thanks [Just-Learned-It](https://github.com/Just-Learned-It))

### Changed

- Switch from Travis CI to GitHub Actions
- Adopt [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format

## 2.2.0 - 2021-08-04

- Add algorithmic function that is bound to a Dart handler function, including parser support (thanks [kamimark](https://github.com/kamimark))

## 2.1.1 - 2021-05-02

- Fix inaccuracies in sin/cos/tan when using math.pi (machine pi) (thanks [mbullington](https://github.com/mbullington))

## 2.1.0 - 2021-03-17

- Bumped to stable release.

## 2.1.0-nullsafety.0 - 2021-03-12

- Drop support for Dart SDK versions below 2.12.0
- Migrate to null safety (thanks [albertodev01](https://github.com/albertodev01))

## 2.0.2 - 2021-01-08

- Lower precedence of unary minus below power operator to match common
  mathematics conventions so that `-x^y` is parsed as `-(x^y)` instead of `(-x)^y`

## 2.0.1 - 2020-09-07

- Add ability to unbind variable names (by [wdavies973](https://github.com/wdavies973))
- Fix parsing of `ceil` function (by [pepsin](https://github.com/pepsin))

## 2.0.0 - 2020-03-08

- Drop support for Dart SDK versions below 2.1.1
- Enable `unnecessary_new` lint rule
- Parser throws `FormatException` instead of `StateError` or `ArgumentError` for
  invalid input string
- Remove underscore syntax previously supported for unary minus
- Fix toString() parser compatibility for the following expressions:
  - Logarithm function: Change string representation from `log_b(x)` to `log(b, x)`
  - N-th root function: Change string representation from `nrt_n(x)` to `nrt(n, x)`
  - Exponential function: Change string representation from `exp(x)` to `e(x)`

## 1.1.1 - 2019-04-16

- Package health and maintenance cleanups

## 1.1.0 - 2019-04-16

- Drop support for Dart SDK versions below 2.0.0
- Add arcsin, arccos, arctan functions
- Fix floor and ceil functions
- Update examples and documentation
- Switch to [pedantic](https://pub.dartlang.org/packages/pedantic) analysis
  options

## 1.0.0 - 2018-08-11

- Add support for Dart 2.0
- Drop support for Dart SDK versions below 1.24.0
- Depend on `vector_math` 2.0.0 or newer

## 0.4.0 - 2018-08-10

- Last release to only support Dart 1.x
- Prepare for Dart 2.0
- Enable strong mode
- Analyzer and linter fixes
- Drop support for Dart SDK versions below 1.21.0

## 0.3.0 - 2016-07-09

- Rename `Point3D` to `Point3`
- `Point3` now is a subtype of `Vector3`
- Add mod (%) operator and ceil, floor functions
- Fixing a few missed chain rules in `derive`

## 0.2.0+1 - 2015-12-30

- Depend on `vector_math` 1.4.4 or greater

## 0.2.0 - 2015-11-19

- Add support for basic vector operations
- Switch to using `test` instead of `unittest` package
- **Warning:** Depends on git version of `vector_math` as latest pub release is severely outdated

## 0.1.0 - 2014-07-19

- Add absolute value function (by [markhats](https://github.com/markhats))
- Add sign function
- Improve test coverage
- Adapt string representation of unary minus to standard syntax

## 0.0.9 - 2014-03-30

- To create exponentials, use `e(x)` or `e^x`. Consequently, removed support for `exp(x)`.
- Improve test coverage
- Update dependencies

## 0.0.8 - 2013-12-10

- Bring back standard syntax for unary minus: `-5` works now. (by [markhats](https://github.com/markhats))
- Add parser support for `e^x` additional to `exp(x)`. (by [markhats](https://github.com/markhats))

## 0.0.7 - 2013-11-09

- Introduce nested context/naming scopes
- Improve vector evaluation
- Add some missing methods
- Improve test coverage (custom and composite functions)
- Remove boilerplate code

## 0.0.6 - 2013-11-07

- Add compose operator for functions:
  Use `&` to conveniently create a CompositeFunction from two existing
  functions: `expr = f & g;`
- Improve documentation and dartdoc generation

## 0.0.5 - 2013-11-06

- Minor code cleanup
- Prepare for Dart 1.0

## 0.0.4 - 2013-10-11

- Fix handling of operator associativity
- Add support for default functions to parser
- Add support for unary minus to parser:
  Input with underscore. Instead of `2*-5` use `2*_5`.

## 0.0.3 - 2013-10-09

- Add cli evaluator to examples
- Improve test coverage
- Fix bug in differentiation of Sin and Cos
- Remove support of unary minus in Parser

## 0.0.2 - 2013-10-07

- Improve test coverage
- Improve documentation
- Fix bug in simplification of Minus
- Fix bug in simplification of Times
- Implement evaluation of nth root

## 0.0.1+1 - 2013-10-06

- Improve documentation and examples

## 0.0.1 - 2013-10-04

- Initial release of standalone version


[unreleased]: https://github.com/fkleon/math-expressions/compare/2.7.0...HEAD
[2.7.0-rc.1]: https://github.com/fkleon/math-expressions/compare/2.6.0...2.7.0-rc.1
[2.6.0]: https://github.com/fkleon/math-expressions/compare/2.5.0...2.6.0
[2.5.0]: https://github.com/fkleon/math-expressions/compare/2.4.0...2.5.0
[2.4.0]: https://github.com/fkleon/math-expressions/compare/2.3.1...2.4.0
[2.3.1]: https://github.com/fkleon/math-expressions/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/fkleon/math-expressions/compare/2.2.0...2.3.0
