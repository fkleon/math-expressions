/**
 * A simple extension to the unittest library.
 * Supports grouping of tets by defining [TestSet]s and the execution of
 * sets by a [TestExecutor].
 * 
 * This library was developed prior to the existence of dedicated test
 * frameworks like [bench](http://pub.dartlang.org/packages/bench), but
 * still gets the job done.
 */
library test_framework;

import 'package:unittest/unittest.dart';

/**
 * Allows the automatic execution of several [TestSet]s.
 */
class TestExecutor {

  /**
   * Creates an empty test executor.
   */
  TestExecutor(): this.testSets = new List();

  /**
   * Creates a test executor with given test sets.
   */
  TestExecutor.initWith(this.testSets);

  /// Contains all registered test sets.
  List<TestSet> testSets;

  /**
   * Registers the given test set for execution.
   */
  void registerTestSet(TestSet set) => testSets.add(set);

  /**
   * Executes this test suite.
   */
  void runTests() {
    // For each test set, create a test group with the set's name,
    // initialize the tests and create test calls for each test function
    // offered by the set.
    for (TestSet set in testSets) {
      group(set.name, () {
        setUp(set.initTests);
        set.testFunctions.forEach((k,v) {
          test(k, v);
        });
      });
    }
  }
}

/**
 * Any set of tests should inherit from TestSet.
 * It offers methods for the test suite to automatically discover and
 * perform its test functions.
 *
 * This allows variable encapsulation to easily create and integrate large
 * test suites.
 */
abstract class TestSet {
  /// Returns the designated name of this test set.
  String get name;

  /**
   * Initializes any requirements for the tests to run.
   */
  void initTests();

  /**
   * Returns a map containing test function names and associated function calls.
   */
  //TODO Use Reflection/Mirror API once available in Dart.
  Map<String, Function> get testFunctions;
}