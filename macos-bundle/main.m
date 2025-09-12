#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    NSString *execDir = [[[NSBundle mainBundle] executablePath]
      stringByDeletingLastPathComponent];
    NSString *binaryPath = [execDir stringByAppendingPathComponent:@"pdf_splitter_bin"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:binaryPath]) {
        // サイレントに失敗するか、アラートを表示するか
        // ここでは何もしない
        [NSApp terminate:self];
        return;
    }

    for (NSString *filename in filenames) {
        @try {
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:binaryPath];
            [task setArguments:@[filename]];
            [task launch];
            [task waitUntilExit];
        } @catch (NSException *exception) {
            // エラー処理
        }
    }

    [NSApp terminate:self];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        [application setDelegate:appDelegate];
        [application run];
    }
    return 0;
}
