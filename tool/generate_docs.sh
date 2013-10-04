#!/bin/bash

# Creates dart doc, excludes third party libraries from drocumentation
$DART_SDK/bin/dartdoc --no-show-private --no-code --out=docs --package-root=../packages/ --exclude-lib dd_entry,unittest,mock,matcher,vector_math,vector_math_64,vector_math_geometry,vector_math_lists,vector_math_operations,frame,lazy_trace,meta,path,pretty_print,stack_trace,stack_trace.src.utils,trace,utils,vm_trace -v "dartdoc_entry_point.dart"
# $DART_SDK/bin/dartdoc --package-root=../packages/ --out=docs tool/dartdoc_entry_point.dart
