//
//  FFLabel.swift
//  FFLabel

import UIKit

@objc
public protocol FFLabelDelegate: NSObjectProtocol {
    @objc optional func labelDidSelectedLinkText(_ label: FFLabel, text: String)
}

open class FFLabel: UILabel {

    open var linkTextColor = UIColor(red:0.00, green:0.36, blue:0.62, alpha:1.00)
    open var selectedBackgroudColor = UIColor(red:0.73, green:0.78, blue:0.85, alpha:1.00)
    open weak var labelDelegate: FFLabelDelegate?
    
    // MARK: - override properties
    override open var text: String? {
        didSet {
            updateTextStorage()
        }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet {
            updateTextStorage()
        }
    }
    
    override open var font: UIFont! {
        didSet {
            updateTextStorage()
        }
    }
    
    override open var textColor: UIColor! {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - upadte text storage and redraw text
    fileprivate func updateTextStorage() {
        if attributedText == nil {
            return
        }

        let attrStringM = addLineBreak(attributedText!)
        regexLinkRanges(attrStringM)
        addLinkAttribute(attrStringM)
        
        textStorage.setAttributedString(attrStringM)
        
        setNeedsDisplay()
    }
    
    /// add link attribute
    fileprivate func addLinkAttribute(_ attrStringM: NSMutableAttributedString) {
        var range = NSRange(location: 0, length: 0)
        var attributes = attrStringM.attributes(at: 0, effectiveRange: &range)
        
        attributes[NSFontAttributeName] = font!
        attributes[NSForegroundColorAttributeName] = textColor
        attrStringM.addAttributes(attributes, range: range)
        
        attributes[NSForegroundColorAttributeName] = linkTextColor
        
        for r in linkRanges {
            attrStringM.setAttributes(attributes, range: r)
        }
    }
    
    /// use regex check all link ranges
    fileprivate let patterns = ["[a-zA-Z]*://[a-zA-Z0-9/\\.]*", "#.*?#", "@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*"]
    fileprivate func regexLinkRanges(_ attrString: NSAttributedString) {
        linkRanges.removeAll()
        let regexRange = NSRange(location: 0, length: attrString.string.characters.count)
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let results = regex.matches(in: attrString.string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: regexRange)
            
            for r in results {
                linkRanges.append(r.rangeAt(0))
            }
        }
        
    }
    
    /// add line break mode
    fileprivate func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let attrStringM = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        
        // 崩溃代码
        var attributes = attrStringM.attributes(at: 0, effectiveRange: &range)
        var paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle
        
        if paragraphStyle != nil {
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
        } else {
            // iOS 8.0 can not get the paragraphStyle directly
            paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
            attributes[NSParagraphStyleAttributeName] = paragraphStyle
            
            attrStringM.setAttributes(attributes, range: range)
        }
        
        return attrStringM
    }
    
    open override func drawText(in rect: CGRect) {
        let range = glyphsRange()
        let offset = glyphsOffset(range)

        layoutManager.drawBackground(forGlyphRange: range, at: offset)
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)
    }
    
    fileprivate func glyphsRange() -> NSRange {
        return NSRange(location: 0, length: textStorage.length)
    }
    
    fileprivate func glyphsOffset(_ range: NSRange) -> CGPoint {
        let rect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
        let height = (bounds.height - rect.height) * 0.5
        
        return CGPoint(x: 0, y: height)
    }
    
    // MARK: - touch events
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        selectedRange = linkRangeAtLocation(location)
        modifySelectedAttribute(true)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        if let range = linkRangeAtLocation(location) {
            if !(range.location == selectedRange?.location && range.length == selectedRange?.length) {
                modifySelectedAttribute(false)
                selectedRange = range
                modifySelectedAttribute(true)
            }
        } else {
            modifySelectedAttribute(false)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedRange != nil {
            let text = (textStorage.string as NSString).substring(with: selectedRange!)
            labelDelegate?.labelDidSelectedLinkText!(self, text: text)
            
            let when = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.modifySelectedAttribute(false)
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        modifySelectedAttribute(false)
    }
    
    fileprivate func modifySelectedAttribute(_ isSet: Bool) {
        if selectedRange == nil {
            return
        }
        
        var attributes = textStorage.attributes(at: 0, effectiveRange: nil)
        attributes[NSForegroundColorAttributeName] = linkTextColor
        let range = selectedRange!
        
        if isSet {
            attributes[NSBackgroundColorAttributeName] = selectedBackgroudColor
        } else {
            attributes[NSBackgroundColorAttributeName] = UIColor.clear
            selectedRange = nil
        }
        
        textStorage.addAttributes(attributes, range: range)
        
        setNeedsDisplay()
    }
    
    fileprivate func linkRangeAtLocation(_ location: CGPoint) -> NSRange? {
        if textStorage.length == 0 {
            return nil
        }
        
        let offset = glyphsOffset(glyphsRange())
        let point = CGPoint(x: offset.x + location.x, y: offset.y + location.y)
        let index = layoutManager.glyphIndex(for: point, in: textContainer)
        
        for r in linkRanges {
            if index >= r.location && index <= r.location + r.length {
                return r
            }
        }
        
        return nil
    }
    
    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareLabel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLabel()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainer.size = bounds.size
    }
    
    fileprivate func prepareLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        textContainer.lineFragmentPadding = 0
        
        isUserInteractionEnabled = true
    }
    
    // MARK: lazy properties
    fileprivate lazy var linkRanges = [NSRange]()
    fileprivate var selectedRange: NSRange?
    fileprivate lazy var textStorage = NSTextStorage()
    fileprivate lazy var layoutManager = NSLayoutManager()
    fileprivate lazy var textContainer = NSTextContainer()
}
