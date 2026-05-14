//
//  ContentView.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-14.
//

import SwiftUI
import FoundationModels

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

struct ContentView: View {
	
//	private static let defaultInstructions = "You are a motivational workout coach that provides quotes to inspire and motivate athletes."
	private static let defaultInstructions = ""

	@State private var instructions = Self.defaultInstructions
	private let largeLanguageModel = SystemLanguageModel.default
	@State private var session = LanguageModelSession(instructions: Self.defaultInstructions)
	@State private var tokens: Float = 50
  
	@State private var response: String = ""
	@State private var isLoading: Bool = false

	@State private var myMessage: String = "Hello"
	
	@State private var messages: [Message] = [];
	
	private func updateSessionWithInstructions() {
		//reinit session
		session = LanguageModelSession(instructions: instructions)
		//reset conversations
		response = String()
		messages.removeAll()
		myMessage = String()

	}
	
	private func sendMessageToAi() {
		Task {
			isLoading = true
			response = ""
			defer { isLoading = false }
			
			do {
				//try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
				//let replay = try await session.respond(to: prompt)
				addMessage(text: myMessage, sender: .user)
				let go:GenerationOptions = GenerationOptions(sampling: nil, temperature: 1, maximumResponseTokens: Int(tokens))
				//let replay = try await session.respond(to: prompt)
				let replay = try await session.respond(to: myMessage, options: go)
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
	
	let initSuccess:Bool
	let initErrorMessage:String
	
	init() {
		initSuccess = largeLanguageModel.availability == .available
		switch largeLanguageModel.availability {
		case .available:
			initErrorMessage = String()
		case .unavailable(.deviceNotEligible):
			initErrorMessage = "Your device isn't eligible for Apple Intelligence."
		case .unavailable(.appleIntelligenceNotEnabled):
			initErrorMessage = "Please enable Apple Intelligence in Settings."
		case .unavailable(.modelNotReady):
			initErrorMessage = "The AI model is not ready."
		case .unavailable:
			initErrorMessage = "The AI feature is unavailable for an unkown reason."
		}
	}
	
	private func controlDisabled()->Bool {
		return (!initSuccess) || isLoading
	}
  
	var body: some View {
	  VStack {//main vstack
		  VStack{//vstack - controls
			  Label("Topic", systemImage: "forward.fill")
				  .frame(maxWidth: .infinity, alignment: .leading)
			  HStack {//hstack - topic
				  TextField("Instructions...", text: $instructions, axis: .vertical)
					  .lineLimit(2...2)
						 .textFieldStyle(.roundedBorder)
						 .padding()
						 .disabled(controlDisabled())
				  Spacer()
				  Button(action: {
					  //actions on change topic
					  updateSessionWithInstructions()
				  }) {
					  Image(systemName: "plus.circle.fill")
						  .font(.largeTitle) // Size the icon
				  }
				  .padding()
				  .disabled(controlDisabled())
			  }//hstack - topic
			  VStack {
				  Text("Tokens: \(Int(tokens))")
				  Slider(value: $tokens, in: 1...40)
					  .disabled(controlDisabled())
			  }
			  .padding()
		  }//vstack - controls
		  HStack {//hstack - message
			  TextField("Message to AI...", text: $myMessage, axis: .vertical)
				  .lineLimit(...2)
					 .textFieldStyle(.roundedBorder)
					 .padding()
					 .disabled(controlDisabled())
			  Spacer()
			  Button(action: {
				  //actions on change topic
				  sendMessageToAi()
			  }) {
				  Image(systemName: "plus.circle.fill")
					  .font(.largeTitle) // Size the icon
			  }
			  .padding()
			  .disabled(controlDisabled() || myMessage.isEmpty)
		  }//hstack - message
		  
		  Spacer()
		  
		  if( initSuccess )
		  {//init success
			  if response.isEmpty {
				if isLoading {
				  ProgressView()
				} else {
				  Text("Tap the button to get a response")
					.foregroundStyle(.tertiary)
					.multilineTextAlignment(.center)
					.font(.title)
				}
			  } else {
				Text(response)
				  .multilineTextAlignment(.center)
				  //.font(.largeTitle)
				  //.bold()
			  }
		  }//init success
		  else
		  {//init failed
			  Text(initErrorMessage)
		  }//init failed
		  
		  Spacer()
		
//		  Button {
//			  sendMessageToAi()
//		  } label: {
//			Text("Welcome")
//			  .font(.largeTitle)
//			  .padding()
//		  }
//		  .buttonStyle(.borderedProminent)
//		  .buttonSizing(.flexible)
//		  .glassEffect(.regular.interactive())

		  ScrollViewReader { proxy in
			  ScrollView {//scroll view
				  VStack(spacing: 12) {
					  ForEach(messages) { message in
						   MessageBubble(message: message)
							   .id(message.id)
					   }
				   }
				   .padding(.horizontal, 16)
				   .padding(.top, 8)
			   }//scroll view
			  .onChange(of: messages) { _, newMessages in //scroll view on change messages
				  guard let lastId = newMessages.last?.id else { return }
				  withAnimation(.easeOut(duration: 0.25)) {
					  proxy.scrollTo(lastId, anchor: .bottom)
				  }
			  }//scroll view on change messages
		  }//scroll view reader
		  
	  }//main vstack
	  .padding()
	  .tint(.purple)
	}//view
}

#Preview {
  ContentView()
}
