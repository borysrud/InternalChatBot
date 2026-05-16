//
//  MessageBubble.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-16.
//

import Foundation
import SwiftUI

struct MessageBubble: View {
	let message: Message
	
	var isUser: Bool {
		message.sender == .user
	}
	
	var body: some View {
		HStack {
			if isUser { Spacer(minLength: 50) }
			
			Text(message.text)
				.padding(.horizontal, 16)
				.padding(.vertical, 10)
				.background(isUser ? Color.blue : Color(.systemGray))
				.foregroundColor(isUser ? .white : .primary)
				.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
			
			if !isUser { Spacer(minLength: 50) }
		}
	}
}

