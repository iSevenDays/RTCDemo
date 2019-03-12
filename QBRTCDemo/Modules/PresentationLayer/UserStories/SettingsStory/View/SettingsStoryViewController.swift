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
	@objc func setupInitialState() {
		
	}
	
	func reloadSettings(_ settings: [SettingsSection]) {
		self.settingsSections = settings
		tableView.reloadData()
	}
	
	func settingAtIndexPath(_ indexPath: IndexPath) -> SettingModel {
		let settingsSection = settingsSections[indexPath.section]
		let setting = settingsSection.settings[indexPath.row]
		return setting
	}
}

// MARK: - UITableViewDelegate
extension SettingsStoryViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return settingsSections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsSections[section].settings.count
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let setting = settingAtIndexPath(indexPath)
		output?.didSelectSettingModel(setting)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let setting = settingAtIndexPath(indexPath)
		
		switch setting.type {
		case let .subtitle(label: label, subLabel: subLabel, selected: selected):
			
			let cell: UITableViewCell = {
				let reuseIdentifier = "subtitleCell"
				guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
					// Never fails:
					return UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
				}
				return cell
			}()
			
			cell.textLabel?.text = label
			cell.detailTextLabel?.text = subLabel
			if selected {
				cell.accessoryType = .checkmark
			} else {
				cell.accessoryType = .none
			}
			return cell
		}
	}
}
