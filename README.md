# Shift
Shift is just a tiny category that adds a cute little state machine to NSObject. It's also a little bit of a learning project
that turns out to be a little bit useful at times.

## Usage:
It's very simple to use, there really isn't a lot to it.

```objective-c
#import "NSObject+Shift.h"

// First we create an object.
NSString *string = @"Hello world";

// Set a state for it.
string.shiftState = @"inactive";

// Setup some call backs when that state changes.

[string on:@"active" do:^(id self) {
  NSLog(@"I have become active");
}];

[string before:@"active" do:^(id self) {
  NSLog(@"Going to print this before i become active");
}];

[string after:@"inactive" do:^(id self) {
  NSLog(@"Going to print after state has changed");
}];

[string when:@"inactive" transitionsTo:@"active" do:^(id self) {
  NSLog(@"OMG, My state is transitioning to!!");
}];

[string when:@"active" transitionsFrom:@"inactive" do:^(id self) {
  NSLog(@"OMG, My state is transitioning from!");
}];


````


***

* [Github](http://www.github.com/wess)
* [@WessCope](http://www.twitter.com/wesscope)

## License
Read LICENSE file for more info.
