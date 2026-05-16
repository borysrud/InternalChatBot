//
//  ViewModel.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-16.
//

import Foundation
import Combine
import FoundationModels

final class ViewModel: ObservableObject {
    static let shared = ViewModel()

    private init() {
    }
	
	private static let defaultInstructions = "You are a motivational workout coach that provides quotes to inspire and motivate athletes."
	//private static let defaultInstructions = ""
	@Published var instructions = defaultInstructions
	
	let largeLanguageModel = SystemLanguageModel.default
	var aiSession = LanguageModelSession(instructions: ViewModel.defaultInstructions)
	@Published var tokens: Float = 50

	@Published var response: String = ""
	@Published var isLoading: Bool = false

	@Published var myMessage: String = "Hello"
	
	@Published var messages: [Message] = []
	
	func updateSessionWithInstructions() {
		//reinit session
		aiSession = LanguageModelSession(instructions: instructions)
		//reset conversations
		response = String()
		messages.removeAll()
		myMessage = String()
	}
	
	func sendMessageToAi() {
		Task {
			let tmpMessage = myMessage
			myMessage = String()
			isLoading = true
			response = ""
			defer { isLoading = false }
			
			do {
				//try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
				//let replay = try await session.respond(to: prompt)
				addMessage(text: tmpMessage, sender: .user)
				let go:GenerationOptions = GenerationOptions(sampling: nil, temperature: 1, maximumResponseTokens: Int(tokens))
				//let replay = try await session.respond(to: prompt)
				let replay = try await aiSession.respond(to: tmpMessage, options: go)
				addMessage(text: replay.content, sender: .ai)
				
			  response = replay.content
			} catch {
				response = "Failed to get response: \(error.localizedDescription)"
				addMessage(text: response, sender: .system)
			}

			
		}
	}
	
	func addMessage(text: String, sender: Message.Sender) {
		let message = Message(text: text, sender: sender)
		messages.append(message)
	}

}
