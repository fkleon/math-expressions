#!/bin/bash

# Creates dart doc, excludes third party libraries from being documented
$DART_SDK/bin/dartdoc --no-show-private --no-code --package-root=../packages/ --out=docs --include-lib math_expressions,math_expressions_test,test_framework -v "../lib/math_expressions.dart"
