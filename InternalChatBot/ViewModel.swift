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

    init() {
    }
	
	private static let defaultInstructions = ""
	@Published var instructions = "You are a motivational workout coach that provides quotes to inspire and motivate athletes."
	
	var aiSession = LanguageModelSession(instructions: ViewModel.defaultInstructions)
	var mySession: LanguageModelSession? = nil
	
	@Published var tokens: Float = 50

	@Published var isLoading: Bool = false

	@Published var messages: [Message] = []
	
	@Published var autoReplyFromMySide: Bool = false{
		didSet{
			if autoReplyFromMySide {
				mySession = LanguageModelSession(instructions: instructions)
			} else {
				mySession = nil
			}
		}
	}
	
	func updateSessionWithInstructions() {
		//reinit session
		aiSession = LanguageModelSession(instructions: instructions)
		
		if autoReplyFromMySide {
			mySession = LanguageModelSession(instructions: instructions)
		} else {
			mySession = nil
		}
		
		//reset conversations
		messages.removeAll()
	}
	
	func sendMessageToAi(withMessage message: String) {
		Task {
			isLoading = true
			defer { isLoading = false }
			
			do {
				//try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
				//let replay = try await session.respond(to: prompt)
				addMessage(text: message, sender: .user)
				let go:GenerationOptions = GenerationOptions(sampling: nil, temperature: 1, maximumResponseTokens: Int(tokens))
				//let replay = try await session.respond(to: prompt)
				let replay = try await aiSession.respond(to: message, options: go)
				let replayContent = replay.content
				addMessage(text: replay.content, sender: .ai)
				
				if (autoReplyFromMySide) {
					Task {
						try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)//delay
						//send this to mySession
						if(mySession != nil) && autoReplyFromMySide {//session still exists
							let go:GenerationOptions = GenerationOptions(sampling: nil, temperature: 1, maximumResponseTokens: Int(tokens))
							let myReplay = try await mySession!.respond(to: replayContent, options: go)
							let myReplayContent = myReplay.content
							sendMessageToAi(withMessage: myReplayContent)
						}
					}
				}
			} catch {
				let pseudoResponse = "Failed to get response: \(error.localizedDescription)"
				addMessage(text: pseudoResponse, sender: .system)
			}

			
		}
	}
	
	func addMessage(text: String, sender: Message.Sender) {
		let message = Message(text: text, sender: sender)
		messages.append(message)
	}

	static func getAvailability() -> (available: Bool, errorMessage: String) {
		switch SystemLanguageModel.default.availability {
		case .available:
			return(true, "")
		case .unavailable(.deviceNotEligible):
			return(false, "Your device isn't eligible for Apple Intelligence.")
		case .unavailable(.appleIntelligenceNotEnabled):
			return(false, "Please enable Apple Intelligence in Settings.")
		case .unavailable(.modelNotReady):
			return(false, "The AI model is not ready.")
		case .unavailable:
			return(false, "The AI feature is unavailable for an unkown reason.")
		}
	}
}
