/*
 * test_composition_state.m
 *
 * Build and run:
 *   clang -framework Foundation -o build/test_composition_state Tests/test_composition_state.m Sources/DKSTCompositionState.m
 *   ./build/test_composition_state
 */

#import "../Sources/DKSTCompositionState.h"
#import <Foundation/Foundation.h>

static int _passed = 0;
static int _failed = 0;

#define ASSERT_TRUE(cond, msg) do { \
  if ((cond)) { _passed++; } \
  else { _failed++; NSLog(@"FAIL: %@", msg); } \
} while(0)

#define ASSERT_STR(actual, expected, msg) do { \
  NSString *_a = (actual) ?: @"(nil)"; \
  NSString *_e = (expected) ?: @"(nil)"; \
  if ([_a isEqualToString:_e]) { _passed++; } \
  else { _failed++; NSLog(@"FAIL: %@ expected '%@', got '%@'", msg, _e, _a); } \
} while(0)

static void assertRange(NSRange actual, NSRange expected, NSString *msg) {
  if (NSEqualRanges(actual, expected)) {
    _passed++;
  } else {
    _failed++;
    NSLog(@"FAIL: %@ expected {%lu,%lu}, got {%lu,%lu}",
          msg,
          (unsigned long)expected.location,
          (unsigned long)expected.length,
          (unsigned long)actual.location,
          (unsigned long)actual.length);
  }
}

static void testBufferHistory(void) {
  DKSTCompositionState *state = [[DKSTCompositionState alloc] init];

  [state updateBufferContents:@"ㅎ"];
  ASSERT_STR([state bufferContents], @"ㅎ", @"buffer stores first value");
  ASSERT_STR([state previousBufferContents], @"(nil)", @"previous starts nil");
  ASSERT_TRUE([state currentlyEditing], @"editing starts when buffer is nonempty");

  [state updateBufferContents:@"하"];
  ASSERT_STR([state bufferContents], @"하", @"buffer stores changed value");
  ASSERT_STR([state previousBufferContents], @"ㅎ", @"previous keeps old value");

  [state updateBufferContents:@"하"];
  ASSERT_STR([state previousBufferContents], @"ㅎ", @"same value does not churn previous");

  [state release];
}

static void testDirectReplacementRange(void) {
  DKSTCompositionState *state = [[DKSTCompositionState alloc] init];

  NSRange replacement =
      [state directReplacementRangeForSelectedRange:NSMakeRange(12, 0)
                                     composedLength:2];
  assertRange(replacement, NSMakeRange(10, 2),
              @"direct replacement backs up by composed length");

  [state noteInsertedTextWithReplacementRange:NSMakeRange(20, 1)
                            insertionLocation:NSNotFound
                              committedLength:1
                               composedLength:2];
  replacement =
      [state directReplacementRangeForSelectedRange:NSMakeRange(NSNotFound, 0)
                                     composedLength:2];
  assertRange(replacement, NSMakeRange(21, 2),
              @"direct replacement falls back to inline range");

  [state release];
}

static void testInlineRangeAfterInsert(void) {
  DKSTCompositionState *state = [[DKSTCompositionState alloc] init];

  [state noteInsertedTextWithReplacementRange:NSMakeRange(NSNotFound, 0)
                            insertionLocation:5
                              committedLength:1
                               composedLength:2];
  assertRange([state inlineRange], NSMakeRange(6, 2),
              @"inline range starts after committed text");
  ASSERT_TRUE([state currentlyEditing], @"composed text marks active editing");

  [state noteInsertedTextWithReplacementRange:NSMakeRange(3, 1)
                            insertionLocation:9
                              committedLength:0
                               composedLength:1];
  assertRange([state inlineRange], NSMakeRange(3, 1),
              @"replacement range wins over insertion location");

  [state noteInsertedTextWithReplacementRange:NSMakeRange(3, 1)
                            insertionLocation:9
                              committedLength:1
                               composedLength:0];
  assertRange([state inlineRange], NSMakeRange(NSNotFound, 0),
              @"empty composition clears inline range");
  ASSERT_TRUE(![state currentlyEditing], @"empty composition ends editing");

  [state release];
}

static void testExpectedSelectionAndFallback(void) {
  DKSTCompositionState *state = [[DKSTCompositionState alloc] init];

  NSUInteger expected =
      [state expectedSelectedLocationForInsertionLocation:7
                                         committedLength:1
                                          composedLength:2];
  ASSERT_TRUE(expected == 10, @"expected cursor advances by commit and compose");
  ASSERT_TRUE([state selectedRange:NSMakeRange(10, 0)
           matchesExpectedLocation:expected],
              @"matching cursor is accepted");
  ASSERT_TRUE([state shouldFallbackForSelectedRange:NSMakeRange(9, 0)
                                   expectedLocation:expected],
              @"cursor mismatch requests fallback");

  [state setShouldCheckInsertionError:NO];
  ASSERT_TRUE(![state shouldFallbackForSelectedRange:NSMakeRange(9, 0)
                                    expectedLocation:expected],
              @"disabled insertion checks suppress fallback");

  [state release];
}

static void testResetAndMarkedReplacement(void) {
  DKSTCompositionState *state = [[DKSTCompositionState alloc] init];

  [state updateBufferContents:@"가"];
  [state markReplacementRange:NSMakeRange(4, 2)];
  assertRange([state replacementRange], NSMakeRange(4, 2),
              @"marked replacement range is stored");
  ASSERT_STR([state bufferContents], @"(nil)",
             @"marking replacement clears buffer contents");

  [state reset];
  assertRange([state inlineRange], NSMakeRange(NSNotFound, 0),
              @"reset clears inline range");
  assertRange([state replacementRange], NSMakeRange(NSNotFound, 0),
              @"reset clears replacement range");
  ASSERT_TRUE([state shouldCheckInsertionError],
              @"reset enables insertion error checks");
  ASSERT_TRUE(![state shouldForceMarkedText],
              @"reset clears forced marked text");

  [state release];
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSLog(@"=== DKSTCompositionState Unit Tests ===");
    testBufferHistory();
    testDirectReplacementRange();
    testInlineRangeAfterInsert();
    testExpectedSelectionAndFallback();
    testResetAndMarkedReplacement();
    NSLog(@"=== Results: %d passed, %d failed ===", _passed, _failed);
    return _failed == 0 ? 0 : 1;
  }
}
