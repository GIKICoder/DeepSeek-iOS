//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/17.
//

import Foundation
import UIKit
import MPITextKit
import GMarkdown
import IQListKit

@MainActor
public class ChatMDTableCell: ChatContentCell {

    let table = GMarkTableView()
    var markChunk: GMarkChunk?
    
    public private(set) lazy var style: GMarkTableStyle = {
        let style = GMarkTableStyle.appearance
        style.cornerRadius = 6
        style.colGap = 1
        style.gapColor = UIColor(hex: "#F2F2FF")
        return style
    }()

    var tableStyle: TableStyle {
        guard let tableStyle = markChunk?.style.tableStyle else {
            return DefaultTableStyle()
        }
        return tableStyle
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        table.backgroundColor = .clear
        table.register(GMarkTableRichLabelCell.self, forCellReuseIdentifier: "GMarkTableRichLabelCell")
        table.dataSource = self
        table.style = style
        table.layer.cornerRadius = 6
        table.layer.masksToBounds = true
        messageView.addSubview(table)
        table.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0))
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chunk: GMarkChunk) {
        markChunk = chunk
        table.reloadData()
    }

    func headerEmpty() -> Bool {
        return (markChunk?.tableRender?.headerRenders.isEmpty) != nil
    }

    func headerRenders() -> [MPITextRenderer] {
        if let renders = markChunk?.tableRender?.headerRenders {
            return renders
        }
        return []
    }

    func bodyRenders() -> [[MPITextRenderer]] {
        if let renders = markChunk?.tableRender?.bodyRenders {
            return renders
        }
        return [[]]
    }

    func tableRenders() -> [[MPITextRenderer]] {
        let header = headerRenders()
        let headerArray = header.isEmpty ? [] : [header]
        let body = bodyRenders()
        let result = headerArray + body
        return result
    }
    
    // MARK: - Public
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        if let layout = layout as? ChatMarkdownLayout {
            configure(with: layout.chunk)
        }
    }

}

extension ChatMDTableCell: GMarkTableViewDataSource {
    
    // MARK: GMarkTableViewDataSource

    public func numberOfRows(in _: GMarkTableView) -> Int {
        return tableRenders().count
    }

    public func numberOfCols(in _: GMarkTableView) -> Int {
        return headerRenders().count
    }

    public func numberOfLockingRows(in _: GMarkTableView) -> Int {
        return 0
    }

    public func numberOfLockingCols(in _: GMarkTableView) -> Int {
        return 0
    }

    public func table(_: GMarkTableView, lengthForRow row: Int) -> CGFloat {
        var height: CGFloat = tableStyle.cellHeight
        let renderArray = tableRenders()
        if let renders = renderArray[safe2: row] {
            for textRender in renders {
                let textheight = textRender.size().height
                height = max(height, textheight + tableStyle.cellPadding.top + tableStyle.cellPadding.bottom)
            }
        }
        return max(height, tableStyle.cellHeight)
    }

    public func table(_: GMarkTableView, lengthForCol col: Int) -> CGFloat {
        let renderArray = tableRenders()
        var maxColWidth: CGFloat = 0
        for row in renderArray {
            if col < row.count {
                if let textRender = row[safe2: col] {
                    let textWidth = textRender.size().width
                    maxColWidth = max(maxColWidth, textWidth + tableStyle.cellPadding.left + tableStyle.cellPadding.right)
                }
            }
        }
        return max(maxColWidth, tableStyle.cellWidth)
    }

    public func table(_ table: GMarkTableView, cellForIndexPath indexPath: TabIndexPath) -> GMarkTableViewCell? {
        guard let cell = table.dequeueReusableCell(withIdentifier: "GMarkTableRichLabelCell", for: indexPath) as? GMarkTableRichLabelCell else {
            return nil
        }

        let renders = tableRenders()

        if indexPath.row < renders.count && indexPath.col < renders[indexPath.row].count {
            let textRender = renders[indexPath.row][indexPath.col]
            cell.configure(textRender)
        }

        cell.contentInset = tableStyle.cellPadding

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .black.withAlphaComponent(0.06)
        } else {
            cell.backgroundColor = UIColor(hex: "#F2F4F7")
        }

        return cell
    }
    
}
