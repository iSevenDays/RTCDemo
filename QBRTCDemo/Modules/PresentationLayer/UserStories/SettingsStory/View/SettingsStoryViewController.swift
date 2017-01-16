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
	
	var settings: [SettingModel] = []
	
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
	
	func reloadSettings(settings: [SettingModel]) {
		self.settings = settings
		tableView.reloadData()
	}
}

// MARK: - UITableViewDelegate
extension SettingsStoryViewController {
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		output?.didSelectSettingModel(settings[indexPath.row])
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let setting = settings[indexPath.row]
		switch setting.type {
		case let .switcher(enabled: enabled):
			
			let cell = tableView.dequeueReusableCellWithIdentifier(switcherCellIdentifier, forIndexPath: indexPath) as! SettingsSwitchTableViewCell
			cell.label.text = setting.label
			cell.switchControl.on = enabled
			return cell
		}
	}
}
