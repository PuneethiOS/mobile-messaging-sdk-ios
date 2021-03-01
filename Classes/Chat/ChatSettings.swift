//
//  ChatSettings.swift
//  MobileMessaging
//
//  Created by Andrey Kadochnikov on 07/11/2017.
//

import Foundation
import WebKit

public class ChatSettings: NSObject {
	
    public static let sharedInstance = ChatSettings()
    
    func postAppearanceChangedNotification() {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.mobile-messaging.chat.settings.updated"), object: self)
	}
	
	public var title: String? { didSet { postAppearanceChangedNotification() } }
	
	public var sendButtonTintColor: UIColor? { didSet { postAppearanceChangedNotification() } }
	
	public var navBarItemsTintColor: UIColor? { didSet { postAppearanceChangedNotification() } }
	
	public var navBarColor: UIColor? { didSet { postAppearanceChangedNotification() } }
	
	public var navBarTitleColor: UIColor? { didSet { postAppearanceChangedNotification() } }
    
    public var attachmentPreviewBarsColor: UIColor? { didSet { postAppearanceChangedNotification() } }
    
    public var attachmentPreviewItemsColor: UIColor? { didSet { postAppearanceChangedNotification() } }
	
    func update(withChatWidget widget: ChatWidget) {
        if let widgetTitle = widget.title, title == nil {
            title = widgetTitle
        }
        if let primaryColor = widget.primaryColor {
            let color = UIColor(hexString: primaryColor)
            if sendButtonTintColor == nil {
                sendButtonTintColor = color
            }
            if navBarColor == nil {
                navBarColor = color
            }
        }
    }
}

class ChatSettingsManager {
	static let sharedInstance = ChatSettingsManager()
	var objects = Array<Weak<AnyObject>>()
	
	init() {
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func register(object: ChatSettingsApplicable) {
		if objects.isEmpty {
			NotificationCenter.default.addObserver(self, selector: #selector(ChatSettingsManager.appearanceUpdated), name: NSNotification.Name(rawValue: "com.mobile-messaging.chat.settings.updated"), object: nil)
		}
		
		objects.append(Weak(value: object))
	}
	
	@objc func appearanceUpdated() {
		objects.forEach { obj in
			if let appearanceObject = obj.value as? ChatSettingsApplicable {
				appearanceObject.applySettings()
			}
		}
	}
}

//For Plugins
extension ChatSettings {
    struct Keys {
        static let title = "title"
        static let sendButtonColor = "sendButtonColor"
        static let navigationBarItemsColor = "navigationBarItemsColor"
        static let navigationBarColor = "navigationBarColor"
        static let navigationBarTitleColor = "navigationBarTitleColor"
    }

    public func configureWith(rawConfig: [String: AnyObject]) {
        if let title = rawConfig[ChatSettings.Keys.title] as? String {
            self.title = title
        }
        if let sendButtonColor = rawConfig[ChatSettings.Keys.sendButtonColor] as? String {
            self.sendButtonTintColor = UIColor(hexString: sendButtonColor)
        }
        if let navigationBarItemsColor = rawConfig[ChatSettings.Keys.navigationBarItemsColor] as? String {
            self.navBarItemsTintColor = UIColor(hexString: navigationBarItemsColor)
        }
        if let navigationBarColor = rawConfig[ChatSettings.Keys.navigationBarColor] as? String {
            self.navBarColor = UIColor(hexString: navigationBarColor)
        }
        if let navigationBarTitleColor = rawConfig[ChatSettings.Keys.navigationBarTitleColor] as? String {
            self.navBarTitleColor = UIColor(hexString: navigationBarTitleColor)
        }
    }
}

