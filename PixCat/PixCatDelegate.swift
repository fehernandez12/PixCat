//
//  PixCatDelegate.swift
//  PixCat
//
//  Created by Felipe Hernández on 15/08/25.
//
import Cocoa

class PixCatDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var globalMonitor: Any?
    var isMoving = false
    var idleDebounceWorkItem: DispatchWorkItem?
    var animTimer: Timer?
    let runFrames = [NSImage(named: "cat_run1"), NSImage(named: "cat_run2")].compactMap { $0 }
    var frameIndex = 0
    let idleImage = NSImage(named: "cat_idle")
    
    func getTimerInstance() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self, let button = self.statusItem.button else { return }
            if self.isMoving, !self.runFrames.isEmpty {
                self.frameIndex = (self.frameIndex + 1) % self.runFrames.count
                button.image = self.runFrames[self.frameIndex]
            } else {
                button.image = self.idleImage
            }
            button.image?.isTemplate = false
        }
    }
    
    func getGlobalMonitor() -> Any? {
        return NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) {
            [weak self] _ in
            guard let self else { return }
            self.isMoving = true
            self.idleDebounceWorkItem?.cancel()
            let work = DispatchWorkItem{ [weak self] in self?.isMoving = false }
            self.idleDebounceWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.menu = createMenu()
        let btn = statusItem.button
        btn?.imageScaling = .scaleProportionallyUpOrDown
        btn?.image = NSImage(named: "cat_idle")
        btn?.image?.isTemplate = false
        
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        
        globalMonitor = getGlobalMonitor()
        
        animTimer = getTimerInstance()
    }
    
    func createMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit PixCat", action: #selector(quit), keyEquivalent: "q"))
        return menu
    }
    
    @objc func statusItemClicked(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp || event.type == .rightMouseDown {
            
        }
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
