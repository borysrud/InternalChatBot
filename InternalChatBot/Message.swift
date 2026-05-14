//
//  Message.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-14.
//

import Foundation

import SwiftUI

struct Message: Identifiable, Equatable {

	enum Sender {
		case user
		case ai
		case system
	}
	
	let id = UUID()
	let text: String
	let sender: Sender
	let timestamp = Date()
}
