//
//  ContentView.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-14.
//

import SwiftUI
import FoundationModels

extension View {
	func roundedBorder() -> some View {
		self.padding()
		.textFieldStyle(.roundedBorder)
	}
}

struct ContentView: View {
	
	@ObservedObject var viewModel = ViewModel.shared
	
	let initSuccess:Bool
	let initErrorMessage:String
	
	init() {
		let viewModel = ViewModel.shared
		initSuccess = viewModel.largeLanguageModel.availability == .available
		switch viewModel.largeLanguageModel.availability {
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
		return (!initSuccess) || viewModel.isLoading
	}
  
	var body: some View {
	  VStack {//main vstack
		  VStack{//vstack - controls
			  Label("Topic", systemImage: "forward.fill")
				  .frame(maxWidth: .infinity, alignment: .leading)
			  HStack {//hstack - topic
				  TextField("Instructions...", text: $viewModel.instructions, axis: .vertical)
					  .lineLimit(2...2)
					  .roundedBorder()
					  .disabled(controlDisabled())
					  .onSubmit {
						  viewModel.updateSessionWithInstructions()
					  }
				  Spacer()
				  Button(action: {
					  //actions on change topic
					  viewModel.updateSessionWithInstructions()
				  }) {
					  Image(systemName: "plus.circle.fill")
						  .font(.largeTitle) // Size the icon
				  }
				  .padding()
				  .disabled(controlDisabled())
			  }//hstack - topic
			  VStack {
				  Text("Tokens: \(Int(viewModel.tokens))")
				  Slider(value: $viewModel.tokens, in: 1...40)
					  .disabled(controlDisabled())
			  }
			  .padding()
		  }//vstack - controls
		  HStack {//hstack - message
			  TextField("Message to AI...", text: $viewModel.myMessage, axis: .vertical)
				  .lineLimit(...2)
				  .roundedBorder()
				  .disabled(controlDisabled())
				  .onSubmit {
					  viewModel.sendMessageToAi()
				  }
			  Spacer()
			  Button(action: {
				  //actions on change topic
				  viewModel.sendMessageToAi()
			  }) {
				  Image(systemName: "plus.circle.fill")
					  .font(.largeTitle) // Size the icon
			  }
			  .padding()
			  .disabled(controlDisabled() || viewModel.myMessage.isEmpty)
		  }//hstack - message
		  
		  Spacer()
		  
		  if( initSuccess )
		  {//init success
			  if viewModel.response.isEmpty {
				  if viewModel.isLoading {
				  ProgressView()
				} else {
				  Text("Tap the button to get a response")
					.foregroundStyle(.tertiary)
					.multilineTextAlignment(.center)
					.font(.title)
				}
			  } else {
				  Text(viewModel.response)
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
					  ForEach(viewModel.messages) { message in
						   MessageBubble(message: message)
							   .id(message.id)
					   }
				   }
				   .padding(.horizontal, 16)
				   .padding(.top, 8)
			   }//scroll view
			  .onChange(of: viewModel.messages) { _, newMessages in //scroll view on change messages
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
