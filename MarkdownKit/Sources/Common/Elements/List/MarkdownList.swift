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
        // 检查是否为复选框格式
        let originalString = attributedString.string
        let rangeEnd = range.location + range.length

        // 检查列表标记后是否有 [ ] 或 [x] 模式
        if rangeEnd + 4 <= originalString.count {
            let startIndex = originalString.index(originalString.startIndex, offsetBy: rangeEnd)
            let possibleCheckboxEndIndex = originalString.index(startIndex, offsetBy: min(4, originalString.count - rangeEnd))
            let possibleCheckbox = String(originalString[startIndex ..< possibleCheckboxEndIndex]).trimmingCharacters(in: .whitespaces)
            var isCheckbox = false
            var isChecked = false

            // 检测复选框格式
            if possibleCheckbox.hasPrefix("[ ]") {
                isCheckbox = true
                isChecked = false
            } else if possibleCheckbox.hasPrefix("[x]") || possibleCheckbox.hasPrefix("[X]") {
                isCheckbox = true
                isChecked = true
            }

            if isCheckbox {
                // 处理复选框
                let levelIndicatorOffsetList = [1: "", 2: "", 3: "  ", 4: "  ", 5: "    ", 6: "    "]
                guard let offset = levelIndicatorOffsetList[level] else { return }

                // 创建复选框图片
                let checkboxImage = isChecked ? "✅" : "☑️" // 这里可以替换为实际图片
                let checkboxString = "\(offset)\(checkboxImage)  "

                // 替换列表标记
                attributedString.replaceCharacters(in: range, with: checkboxString)
                let updatedRange = NSRange(location: range.location, length: checkboxString.utf16.count)
                attributedString.addAttributes([.paragraphStyle: defaultParagraphStyle()], range: updatedRange)

                // 移除 [ ] 或 [x] 部分（包括前面的空格）
                let checkboxRange = NSRange(location: rangeEnd, length: 4)
                attributedString.replaceCharacters(in: checkboxRange, with: "")

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
        paragraphStyle.paragraphSpacing = 8
        return paragraphStyle
    }

    private func handleCheckbox(_ attributedString: NSMutableAttributedString, range: NSRange, content: String, checked: Bool, level: Int) {
        let levelIndicatorOffsetList = [1: "", 2: "", 3: "  ", 4: "  ", 5: "    ", 6: "    "]
        guard let offset = levelIndicatorOffsetList[level] else { return }
    }
}
