//
//  LocalMessageFetchingOperation.swift
//  MobileMessaging
//
//  Created by Andrey Kadochnikov on 20/09/2017.
//

import Foundation
import UserNotifications

class LocalMessageFetchingOperation : MMOperation {
	
	let notificationExtensionStorage: AppGroupMessageStorage?
	let finishBlock: ([MTMessage]) -> Void
	let userNotificationCenterStorage: UserNotificationCenterStorage
	
	var result = Set<MTMessage>()
	
	init(userNotificationCenterStorage: UserNotificationCenterStorage, notificationExtensionStorage: AppGroupMessageStorage?, finishBlock: @escaping ([MTMessage]) -> Void) {
		self.notificationExtensionStorage = notificationExtensionStorage
		self.finishBlock = finishBlock
		self.userNotificationCenterStorage = userNotificationCenterStorage
		super.init()
	}
	
	override func execute() {
		self.retrieveMessagesFromNotificationServiceExtension(completion: { messages in
			self.logDebug("Retrieved \(messages.count) messages from notification extension storage.")
			self.result.formUnion(messages)
			
			self.retrieveMessagesFromUserNotificationCenter(completion: { messages in
				self.logDebug("Retrieved \(messages.count) messages from notification center.")
				self.result.formUnion(messages)
				self.finish()
			})
		})
	}
	
	private func retrieveMessagesFromNotificationServiceExtension(completion: @escaping ([MTMessage]) -> Void) {
		if let messages = notificationExtensionStorage?.retrieveMessages() {
			if !messages.isEmpty {
				notificationExtensionStorage?.cleanupMessages()
			}
			completion(messages)
		} else {
			completion([])
		}
	}
	
	private func retrieveMessagesFromUserNotificationCenter(completion: @escaping ([MTMessage]) -> Void) {
		userNotificationCenterStorage.getDeliveredMessages(completionHandler: completion)
	}
	
	override func finished(_ errors: [NSError]) {
		logDebug("finished with errors: \(errors)")
		let messages = Array(result)
		finishBlock(messages)
	}
}
