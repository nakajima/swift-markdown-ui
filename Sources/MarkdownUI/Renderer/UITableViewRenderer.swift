//
//  UITableViewRenderer.swift
//
//
//  Created by Pat Nakajima on 4/14/24.
//

import Foundation
import UIKit
import SwiftUI

class BlockNodeCell: UITableViewCell {
	var blockNode: BlockNode!

	init(blockNode: BlockNode, reuseIdentifier: String?) {
		self.blockNode = blockNode
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		self.preservesSuperviewLayoutMargins = false
		self.separatorInset = UIEdgeInsets.zero
		self.selectionStyle = .none
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@available(iOS 16.0, *)
public class TableViewRendererController: UITableViewController {
	let markdown: MarkdownContent

	init(markdown: MarkdownContent) {
		self.markdown = markdown
		super.init(style: .plain)

		tableView.dataSource = self

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(BlockNodeCell.self, forCellReuseIdentifier: "block")
		tableView.layoutMargins = .zero
		tableView.separatorStyle = .none
		print("got blcoks \(markdown.blocks.count)")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		markdown.blocks.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "block", for: indexPath)
		let content = markdown.blocks[indexPath.row]

		cell.contentConfiguration = UIHostingConfiguration {
			TextStyleAttributesReader { attributes in
				content.body
					.foregroundColor(attributes.foregroundColor)
					.background(attributes.backgroundColor)
					.markdownTheme(.gitHub)
			}
		}

		return cell
	}
}

@available(iOS 16.0, *)
public struct TableViewWrapper: UIViewControllerRepresentable {
	let content: String

	public func makeCoordinator() -> Coordinator {
		let controller = TableViewRendererController(markdown: .init(content))
		return Coordinator(content: content, controller: controller)
	}

	public class Coordinator: NSObject, UITableViewDelegate {
		let content: String
		let controller: TableViewRendererController

		init(content: String, controller: TableViewRendererController) {
			self.content = content
			self.controller = controller
		}
	}

	public func makeUIViewController(context: Context) -> MarkdownUI.TableViewRendererController {
		context.coordinator.controller
	}

	public func updateUIViewController(_ uiViewController: MarkdownUI.TableViewRendererController, context: Context) {
		uiViewController.tableView.reloadData()
		if let hostedView = uiViewController.view.subviews.first {
			hostedView.frame = CGRect(origin: .zero, size: uiViewController.tableView.contentSize)
		}
	}

	public init(content: String) {
		print("sup")
		self.content = content
	}
}
