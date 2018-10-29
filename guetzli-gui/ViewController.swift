//
//  ViewController.swift
//  guetzli-gui
//
//  Created by Matthew Davies on 3/17/17.
//  Copyright © 2017 Matthew Davies. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var inFileUrlField: NSTextField!
    @IBOutlet weak var outFileUrlField: NSTextField!
    @IBOutlet weak var qualityField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var compressButton: NSButton!
    @IBOutlet weak var warningField: NSTextField!
    
    @IBOutlet weak var inFolderUrlField: NSTextField!
    @IBOutlet weak var qualityFolderField: NSTextField!
    @IBOutlet weak var progressFolderIndicator: NSProgressIndicator!
    @IBOutlet weak var compressFolderButton: NSButton!
    @IBOutlet weak var installRecursivelyButton: NSButton!
    
    var inFile : URL?
    var outFile : URL?
    var quality = 85
    
    var inFolder : URL?
    var outFolder : URL?
    var qualityFolder = 85
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qualityField.integerValue = quality
        qualityFolderField.integerValue = qualityFolder
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func onOpenFile(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { (result) in
            guard result == .OK else { return }
            
            self.inFile = openPanel.urls[0]
            self.inFileUrlField.stringValue = openPanel.urls[0].path
        }
    }
    
    @IBAction func onOpenFolder(_ sender: AnyObject) {
        let openPanel = NSOpenPanel();
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        
        openPanel.begin { (result) in
            guard result == .OK else { return }
            
            self.inFolder = openPanel.urls[0]
            self.inFolderUrlField.stringValue = openPanel.urls[0].path
        }
        
    }
        
    
    @IBAction func onSaveFile(_ sender: AnyObject) {
        let savePanel = NSSavePanel()
        
        if let inFile = self.inFile {
            savePanel.directoryURL = inFile.baseURL
            savePanel.nameFieldStringValue = inFile.lastPathComponent
        }
        
        savePanel.begin { (result) in
            guard result == .OK, let url = savePanel.url else { return }
            
            self.outFile = url
            self.outFileUrlField.stringValue = url.path
        }
    }
    
    @IBAction func qualityDidChange(_ sender: NSTextField) {
        if sender.integerValue < 70 {
            sender.integerValue = 70
        }
       
        quality = sender.integerValue
    }
    
    @IBAction func qualityFolderDidChange(_ sender: NSTextField) {
        if sender.integerValue < 84 {
            sender.integerValue = 84
        }
        
        qualityFolder = sender.integerValue
    }
    
    @IBAction func sliderDidChange(_ sender: NSSlider) {
        qualityField.integerValue = sender.integerValue
        quality = sender.integerValue
        
        if sender.integerValue < 84 {
            warningField.isHidden = false
        }
        
        if sender.integerValue > 84 {
            warningField.isHidden = true
        }
    }
    
    @IBAction func sliderFolderDidChange(_ sender: NSSlider) {
        qualityFolderField.integerValue = sender.integerValue
        qualityFolder = sender.integerValue
    }
    
    @IBAction func installRecursively(_ sender: NSButton) {
        NSWorkspace.shared.open(NSURL(string: "https://github.com/tanrax/guetzli-recursively/blob/master/README.md")! as URL)
    }
    
    @IBAction func compress(_ sender: NSButton) {
        let binUrl = URL(fileURLWithPath: UserDefaults.standard.string(forKey: "binPath") ?? "/usr/local/bin/guetzli")
        
        guard let inFilePath = inFile?.path else {
            return
        }
        
        guard let outFilePath = outFile?.path else {
            return
        }
        
        qualityField.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        compressButton.isEnabled = false
        compressButton.title = "Compressing..."
        
        Command.execAsync(terminationHandler: { (task) in
            DispatchQueue.main.async(execute: {
                self.progressIndicator.isHidden = true
                self.progressIndicator.stopAnimation(nil)
                self.compressButton.isEnabled = true
                self.compressButton.title = "Compress"
                
                self.qualityField.isEnabled = true
            })
          },
          binUrl.path, "--quality", "\(quality)", inFilePath, outFilePath)
    }
    
    @IBAction func compressFolder(_ sender: NSButton) {
        guard let inFolderPath = inFolder?.path else {
            return
        }
        
        qualityFolderField.isEnabled = false
        progressFolderIndicator.isHidden = false
        progressFolderIndicator.startAnimation(nil)
        compressFolderButton.isEnabled = false
        compressFolderButton.title = "Compressing..."
        
        Command.execAsync(terminationHandler: { (task) in
            DispatchQueue.main.async(execute: {
                self.progressFolderIndicator.isHidden = true
                self.progressFolderIndicator.stopAnimation(nil)
                self.compressFolderButton.isEnabled = true
                self.compressFolderButton.title = "Compress"
                
                self.qualityFolderField.isEnabled = true
            })
        },
                          "guetzli_recursively --quality", "\(qualityFolder)", inFolderPath)
    }
}


