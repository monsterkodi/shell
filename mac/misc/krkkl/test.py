from PyObjCTools import AppHelper
from AppKit import *
from Saver import Saver

width, height = 1400, 700

def Window(title, width, height, view=None):
    window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
        ((0,0),(width,height)),
        NSTitledWindowMask |
        NSClosableWindowMask |
        NSMiniaturizableWindowMask |
        NSResizableWindowMask,
        NSBackingStoreBuffered,
        False)
    window.setTitle_(title)
    if view:
        window.setContentView_(view)
    window.orderFront_(window)
    return window

class MyAppDelegate(NSObject):

    def applicationDidFinishLaunching_(self, notification):
        rect = ((0,0),(width, height))
        self.window = Window('Saver', width, height)
        content_rect = self.window.contentRectForFrameRect_(rect)
        self.saver = Saver.alloc().initWithFrame_isPreview_(content_rect, False)
        self.window.setContentView_(self.saver)
        self.window_delegate = MyWindowDelegate.alloc().init()
        self.window.setDelegate_(self.window_delegate)
        self.timer = NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            0.005,
            self,
            'nextFrame',
            None,
            True)

    def nextFrame(self):
        self.saver.animateOneFrame()
        self.window.setViewsNeedDisplay_(True)

class MyWindowDelegate(NSObject):

    def windowWillClose_(self, notification):
        NSApp().terminate_(self)


if __name__ == "__main__":
    app_delegate = MyAppDelegate.alloc().init()
    NSApplication.sharedApplication().setDelegate_(app_delegate)
    AppHelper.runEventLoop(installInterrupt=True)


