//
//  MarkdownList.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownList: MarkdownLevelElement {
    fileprivate static let regex = "^( {0,%@}[\\*\\+\\-])\\s+(.+)$"

    open var maxLevel: Int
    open var font: MarkdownFont?
    open var color: MarkdownColor?
    open var separator: String
    open var indicator: String

    open var regex: String {
        let level: String = maxLevel > 0 ? "\(maxLevel)" : ""
        return String(format: MarkdownList.regex, level)
    }

    public init(font: MarkdownFont? = nil, maxLevel: Int = 6, indicator: String = "•",
                separator: String = "  ", color: MarkdownColor? = nil) {
        self.maxLevel = maxLevel
        self.indicator = indicator
        self.separator = separator
        self.font = font
        self.color = color
    }

    open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
        let originalString = attributedString.string
        let rangeEnd = range.location + range.length

        // 确保有足够的字符来检查复选框格式
        if rangeEnd + 4 <= originalString.count {
            let startIndex = originalString.index(originalString.startIndex, offsetBy: rangeEnd)
            let checkboxLength = 4 // "[ ]" 或 "[x]" 的长度（注意：没有前导空格）
            let endIndex = originalString.index(startIndex, offsetBy: min(checkboxLength, originalString.count - rangeEnd))
            let possibleCheckbox = String(originalString[startIndex ..< endIndex])

            var isCheckbox = false
            var isChecked = false
            var checkboxMarkLength = 0

            // 检查复选框格式（注意没有前导空格）
            if possibleCheckbox.hasPrefix("[ ]") {
                isCheckbox = true
                isChecked = false
                checkboxMarkLength = 3 // "[ ]" 长度为3
            } else if possibleCheckbox.hasPrefix("[x]") || possibleCheckbox.hasPrefix("[X]") {
                isCheckbox = true
                isChecked = true
                checkboxMarkLength = 3 // "[x]" 长度为3
            }

            if isCheckbox {
                // 处理复选框：获取缩进偏移量
                let levelIndicatorOffsetList = [1: "", 2: "", 3: "  ", 4: "  ", 5: "    ", 6: "    "]
                guard let offset = levelIndicatorOffsetList[level] else { return }

                // 创建复选框图标字符串
                let checkboxImageName = isChecked ? "checkmark.square" : "square"
                let checkboxSize: CGSize = CGSize(width: 12, height: 12)
                // 创建图片附件
                let attachment = NSTextAttachment()
                #if os(iOS)
                attachment.image = UIImage(systemName: checkboxImageName)
                #elseif os(macOS)
                    attachment.image = NSImage(named: checkboxImageName)
                #endif
                attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: checkboxSize)

                // A. 创建带有图片的属性字符串
                let attachmentString = NSAttributedString(attachment: attachment)

                // B. 创建完整的复选框字符串
                let checkboxAttributedString = NSMutableAttributedString(string: offset)
                checkboxAttributedString.append(attachmentString)
                checkboxAttributedString.append(NSAttributedString(string: " "))

                // 替换列表标记
                attributedString.replaceCharacters(in: range, with: checkboxAttributedString)

                // 更新属性
                let updatedRange = NSRange(location: range.location, length: checkboxAttributedString.length)
                attributedString.addAttributes([.paragraphStyle: defaultParagraphStyle()], range: updatedRange)

                // 移除复选框标记部分
                let checkboxMarkRange = NSRange(location: range.location + checkboxAttributedString.length, length: checkboxMarkLength)
                attributedString.replaceCharacters(in: checkboxMarkRange, with: "")

                return
            }
        }

        let levelIndicatorList = [1: "\(indicator)  ", 2: "\(indicator)  ", 3: "◦  ", 4: "◦  ", 5: "▪︎  ", 6: "▪︎  "]
        let levelIndicatorOffsetList = [1: "", 2: "", 3: "  ", 4: "  ", 5: "    ", 6: "    "]
        guard let indicatorIcon = levelIndicatorList[level],
              let offset = levelIndicatorOffsetList[level] else { return }
        let indicator = "\(offset)\(indicatorIcon)"
        attributedString.replaceCharacters(in: range, with: indicator)
        let updatedRange = NSRange(location: range.location, length: indicator.utf16.count)
        attributedString.addAttributes([.paragraphStyle: defaultParagraphStyle()], range: updatedRange)
    }

    private func defaultParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 12
        paragraphStyle.paragraphSpacing = 4
        return paragraphStyle
    }
}
