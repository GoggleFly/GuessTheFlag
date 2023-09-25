//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by David Ash on 16/06/2023.
//

import SwiftUI

// custom view, useful for decomposition and to adhere to DRY principles
struct FlagImage: View {
    var country: String
    
    var body: some View {
        Image(country)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

// view modifiers allow for own properties and more complex customisation
struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.weight(.semibold))
            .foregroundColor(.blue)
    }
}

// extensions useful for simple changes and to provide a cleaner interface to apply customer view modifiers (e.g. in this case provides a clean method to invoke the 'Title()' view modifier
extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}

struct ContentView: View {
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var alertMessage = ""
    @State private var score = 0
    @State private var round = 1
    @State private var showingRestart = false
    @State private var animationAmount = 0.0
    @State private var opacityAmount = 0.0
    @State private var scaleAmount = 0.0
    @State private var selected: Int? = nil
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var countries = [
        "Estonia",
        "France",
        "Germany",
        "Ireland",
        "Italy",
        "Nigeria",
        "Poland",
        "Russia",
        "Spain",
        "UK",
        "US"].shuffled()
    
    private let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    
    private let rounds = 3
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .titleStyle()
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            selected = number
                            
                            opacityAmount = 0.25
                            scaleAmount = 0.75
                            
                            withAnimation(.interpolatingSpring(stiffness: 15, damping: 3)) {
                                animationAmount += 360
                            }
                            
                            flagTapped(number)
                            
                        } label: {
                            FlagImage(country: countries[number])
                                .accessibilityLabel(labels[countries[number], default: "Unknown flag"])
                        }
                        .rotation3DEffect(.degrees(selected != nil && number == selected ? animationAmount : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(selected != nil && number != selected ? opacityAmount : 1)
                        .scaleEffect(selected != nil && number != selected ? scaleAmount : 1)
                        .animation(.default, value: scaleAmount)

                    }
                    .alert(scoreTitle, isPresented: $showingScore) {
                        Button("Continue", action: askQuestion)
                    } message: {
                        Text(alertMessage)
                    }
                    .alert("Game Over", isPresented: $showingRestart) {
                        Button("Restart", action: restart)
                    } message: {
                        Text("You final score is \(score)")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("Round: \(round) of \(rounds)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func flagTapped(_ number: Int) {
        round += 1
        
        if number == correctAnswer {
            score += 5
            scoreTitle = "Correct"
            alertMessage = "Your score is \(score)"
        } else {
            score -= 2
            scoreTitle = "Wrong"
            alertMessage = "That's the flag for \(countries[number])"
        }
        
        if round > rounds {
            showingRestart = true
        } else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        selected = nil
        
        animationAmount = 0.0
        opacityAmount = 0.0
        scaleAmount = 0.0
    }
    
    func restart() {
        score = 0
        round = 1
        askQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
