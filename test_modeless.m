#import <Foundation/Foundation.h>
#import <InputMethodKit/InputMethodKit.h>

int main() {
    @autoreleasepool {
        Class cls = NSClassFromString(@"IMKActiveCompositionController");
        if (cls) {
            if ([cls respondsToSelector:@selector(modelessUnsupportedApps)]) {
                id apps = [cls performSelector:@selector(modelessUnsupportedApps)];
                NSLog(@"modelessUnsupportedApps: %@", apps);
            } else {
                NSLog(@"does not respond to modelessUnsupportedApps");
            }
        } else {
            NSLog(@"IMKActiveCompositionController not found");
        }
    }
    return 0;
}
