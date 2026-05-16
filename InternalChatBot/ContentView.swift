//
//  ContentView.swift
//  InternalChatBot
//
//  Created by Borys Rud on 2026-05-14.
//

import SwiftUI

extension View {
	func roundedBorder() -> some View {
		self.padding()
		.textFieldStyle(.roundedBorder)
		.tint(.purple)
	}
}

struct ContentView: View {
	
	@StateObject private var viewModel = ViewModel()
	
	@State var myMessage: String = "Hello"

	let initSuccess:Bool
	let initErrorMessage:String
	
	init() {
		let avRes = ViewModel.getAvailability()
		initSuccess = avRes.available
		initErrorMessage = avRes.errorMessage
	}
	
	private func controlsDisabled()->Bool {
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
					  .disabled(controlsDisabled())
					  .onSubmit {
						  myMessage = String()
						  viewModel.updateSessionWithInstructions()
					  }
				  Spacer()
				  Button(action: {
					  //actions on change topic
					  myMessage = String()
					  viewModel.updateSessionWithInstructions()
				  }) {
					  Image(systemName: "plus.circle.fill")
						  .font(.largeTitle) // Size the icon
				  }
				  .padding()
				  .disabled(controlsDisabled())
			  }//hstack - topic
			  VStack {
				  Text("Tokens: \(Int(viewModel.tokens))")
				  Slider(value: $viewModel.tokens, in: 1...40)
					  .disabled(controlsDisabled())
			  }
			  .padding()
		  }//vstack - controls
		  HStack {//hstack - message
			  TextField("Message to AI...", text: $myMessage, axis: .vertical)
				  .lineLimit(...2)
				  .roundedBorder()
				  .disabled(controlsDisabled())
				  .onSubmit {
					  viewModel.sendMessageToAi(withMessage: myMessage)
					  myMessage = String()
				  }
			  Spacer()
			  Button(action: {
				  //actions on change topic
				  viewModel.sendMessageToAi(withMessage: myMessage)
				  myMessage = String()
			  }) {
				  Image(systemName: "plus.circle.fill")
					  .font(.largeTitle) // Size the icon
			  }
			  .padding()
			  .disabled(controlsDisabled() || myMessage.isEmpty)
			  Toggle("Auto Reply", isOn: $viewModel.autoReplyFromMySide)
				  .padding()
				  .disabled(controlsDisabled())
		  }//hstack - message
		  
		  Spacer()
		  
		  if( initSuccess )
		  {//init success
			  if viewModel.isLoading {
				  ProgressView()
			  } else {
//				  Text("Tap the button to get a response")
//					  .foregroundStyle(.tertiary)
//					  .multilineTextAlignment(.center)
//					  .font(.title)
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
	  .roundedBorder()
	}//view
}

#Preview {
  ContentView()
}
