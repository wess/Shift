// NSObject+Shift.m
// 
// Copyright (c) 2013 Wess Cope
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSObject+Shift.h"
#import <objc/runtime.h>

@interface NSObject(ShiftPrivate)
@property (strong, nonatomic) NSMutableDictionary *stateBlocks;
@end

@implementation NSObject(Shift)
static const char *ShiftStateIdentifier         = "shift_state_identifier";
static const char *ShiftStateBlocksIdentifier   = "shift_state_blocks_identifier";

static NSString *const ShiftOnKey       = @"ShiftOnKey";
static NSString *const ShiftBeforeKey   = @"ShiftBeforeKey";
static NSString *const ShiftAfterKey    = @"ShiftAfterKey";
static NSString *const ShiftToKey       = @"ShiftToKey";
static NSString *const ShiftFromKey     = @"ShiftFromKey";

- (void)setShiftState:(NSString *)shiftState
{
    __weak typeof(self) this = self;
    
    NSString *selfState = (NSString *)objc_getAssociatedObject(self, ShiftStateIdentifier);

    if(self.stateBlocks[ShiftToKey])
    {
        NSString *toState       = self.stateBlocks[ShiftToKey][@"to"];
        NSString *fromState     = self.stateBlocks[ShiftToKey][@"from"];
        ShiftBlock block        = self.stateBlocks[ShiftToKey][@"block"];
        
        if([fromState isEqualToString:selfState] && [shiftState isEqualToString:toState])
            block(this);
    }
    
    if(self.stateBlocks[ShiftBeforeKey])
        ((ShiftBlock)self.stateBlocks[ShiftBeforeKey])(this);
    
    objc_setAssociatedObject(self, ShiftStateIdentifier, shiftState, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if(self.stateBlocks[ShiftOnKey])
        ((ShiftBlock)self.stateBlocks[ShiftOnKey])(this);

    if(self.stateBlocks[ShiftAfterKey])
        ((ShiftBlock)self.stateBlocks[ShiftAfterKey])(this);

    if(self.stateBlocks[ShiftFromKey])
    {
        NSString *toState       = self.stateBlocks[ShiftToKey][@"to"];
        NSString *fromState     = self.stateBlocks[ShiftToKey][@"from"];
        ShiftBlock block        = self.stateBlocks[ShiftToKey][@"block"];
        
        if([toState isEqualToString:selfState] && [shiftState isEqualToString:fromState])
            block(this);
    }
}

- (NSString *)shiftState
{
    return (NSString *)objc_getAssociatedObject(self, ShiftStateIdentifier);
}

- (void)setStateBlocks:(NSMutableDictionary *)stateBlocks
{
    objc_setAssociatedObject(self, ShiftStateBlocksIdentifier, stateBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)stateBlocks
{
    NSMutableDictionary *dict = (NSMutableDictionary *)objc_getAssociatedObject(self, ShiftStateBlocksIdentifier);

    if(dict)
        return dict;
    
    dict = [[NSMutableDictionary alloc] init];
    [self setStateBlocks:dict];
    
    return self.stateBlocks;
}

- (void)on:(NSString *)state do:(ShiftBlock)block
{
    self.stateBlocks[ShiftOnKey] = block;
}

- (void)before:(NSString *)state do:(ShiftBlock)block
{
    self.stateBlocks[ShiftBeforeKey] = block;
}

- (void)after:(NSString *)state do:(ShiftBlock)block
{
    self.stateBlocks[ShiftBeforeKey] = block;
}

- (void)when:(NSString *)state transitionsTo:(NSString *)toState do:(ShiftBlock)block
{
    self.stateBlocks[ShiftToKey] = @{@"to": toState, @"from": state, @"block": block};
}

- (void)when:(NSString *)state transitionsFrom:(NSString *)fromState do:(ShiftBlock)block
{
    self.stateBlocks[ShiftFromKey] = @{@"to": state, @"from": fromState, @"block": block};
}


@end
