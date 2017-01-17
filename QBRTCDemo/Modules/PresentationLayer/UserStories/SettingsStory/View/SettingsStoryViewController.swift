//
//  SettingsStorySettingsStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import UIKit

class SettingsStoryViewController: UITableViewController {

    @objc var output: SettingsStoryViewOutput?
	
	var settings: [SettingsSection] = []
	
	let switcherCellIdentifier = "SwitcherTableViewCellIdentifier"
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewIsReady()
    }
}

// MARK: SettingsStoryViewInput

extension SettingsStoryViewController: SettingsStoryViewInput {
	func setupInitialState() {
		
	}
	
	func reloadSettings(settings: [SettingsSection]) {
		self.settings = settings
		tableView.reloadData()
	}
}

// MARK: - UITableViewDelegate
extension SettingsStoryViewController {
	
	func settingAtIndexPath(indexPath: NSIndexPath) -> SettingModel {
		let settingsSection = settings[indexPath.section]
		let setting = settingsSection.settings[indexPath.row]
		return setting
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let setting = settingAtIndexPath(indexPath)
		output?.didSelectSettingModel(setting)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let setting = settingAtIndexPath(indexPath)
		
		switch setting.type {
		case let .subtile(label: label, subLabel: subLabel, selected: selected):
			
			let cell: UITableViewCell = {
				guard let cell = tableView.dequeueReusableCellWithIdentifier("subtileCell") else {
					// Never fails:
					return UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "subtileCell")
				}
				return cell
			}()
			
			cell.textLabel?.text = label
			cell.detailTextLabel?.text = subLabel
			cell.selected = selected
			return cell
		}
	}
}
