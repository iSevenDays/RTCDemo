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
	
	var settingsSections: [SettingsSection] = []
	
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
		self.settingsSections = settings
		tableView.reloadData()
	}
	
	func settingAtIndexPath(indexPath: NSIndexPath) -> SettingModel {
		let settingsSection = settingsSections[indexPath.section]
		let setting = settingsSection.settings[indexPath.row]
		return setting
	}
}

// MARK: - UITableViewDelegate
extension SettingsStoryViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return settingsSections.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsSections[section].settings.count
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let setting = settingAtIndexPath(indexPath)
		output?.didSelectSettingModel(setting)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let setting = settingAtIndexPath(indexPath)
		
		switch setting.type {
		case let .subtitle(label: label, subLabel: subLabel, selected: selected):
			
			let cell: UITableViewCell = {
				let reuseIdentifier = "subtitleCell"
				guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) else {
					// Never fails:
					return UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
				}
				return cell
			}()
			
			cell.textLabel?.text = label
			cell.detailTextLabel?.text = subLabel
			if selected {
				cell.accessoryType = .Checkmark
			} else {
				cell.accessoryType = .None
			}
			return cell
		}
	}
}
