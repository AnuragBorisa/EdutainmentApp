import SwiftUI

struct ContentView: View {
    @State private var number = 2.0
    @State private var noOfQuestion = 5.0
    @State private var currentScore = 0.0
    @State private var userAnswers = [String: String]()
    @State private var isGameOver = false
    @State private var questions = [String: Int]()
    @State private var showAns = false
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var count = 0
    @State private var resetFlag = false
    @State private var animationAmount = 1.0
    

    func generateQuestion() {
        questions.removeAll()
        
        for _ in 0...Int(noOfQuestion) {
            let multiplier = Int(number)
            let multiplicand = Int.random(in: 2...20)
            let question = "\(multiplier) x \(multiplicand) = "
            let answer = multiplier * multiplicand

            questions[question] = answer
        }
    }

    func checkAns(ques: String, userInput: String) {
        count += 1
        
        if (count >= Int(noOfQuestion)) {
            resetFlag = true
        } else {
            showingScore = true
        }
        
        if let correctAns = questions[ques], Int(userInput) == correctAns {
            scoreTitle = "Correct!"
            currentScore += 1
            // If you want to store the correct INT in the dictionary
//            questions[ques] = correctAns
            
        } else {
            scoreTitle = "Incorrect!"
            currentScore -= 1
        }
    }

    func startGame() {
        isGameOver = false
        currentScore = 0
        count = 0
        resetFlag = false
        userAnswers.removeAll()
        generateQuestion()
    }
    

    var body: some View {
        
        NavigationStack {
            ZStack{
                LinearGradient(stops:[
                    .init(color: .blue,location:0.25),
                    .init(color: .green,location:0.75)
                ],startPoint: .top,endPoint: .bottom)
                .ignoresSafeArea()
                List {
                    // Section 1: Pick your table range
                    Section {
                        Text("Select Table of:")
                        Stepper("\(Int(number))", value: $number.animation(
                            .easeInOut(duration: 0.1)
                        ), in: 2...12)
                    }
                    
                    // Section 2: Pick number of questions
                    Section {
                        Text("Select Number of questions:")
                        Stepper("\(Int(noOfQuestion))", value: $noOfQuestion.animation(
                            .easeInOut(duration: 0.1)
                        ), in: 5...20)
                    }
                    
                    // Section 3: The questions themselves
                    Section("Questions") {
                        ForEach(Array(questions.keys), id: \.self) { question in
                            HStack {
                                Text(question)
                                Spacer()
                                
                                // Optionally show the correct answer if showAns is true
                                if showAns {
                                    Text("\(questions[question] ?? 0)")
                                }
                                
                                TextField("Answer", text: Binding(
                                    get: { userAnswers[question, default: ""] },
                                    set: { userAnswers[question] = $0 }
                                ))
                                .keyboardType(.numberPad)
                                .onSubmit {
                                    checkAns(ques: question, userInput: userAnswers[question, default: ""])
                                }
                                
                            }
                        }
                        .animation(
                            .easeInOut(duration:2)
                            .delay(1),
                            value:animationAmount
                        )
                    }
                    
                    // Section 4: Reveal answers + score
                    Section("Controls") {
                        
                        showAns ? Button("Hide Answer"){
                            showAns = false;
                        } : Button("Show Answer"){
                            showAns = true
                        }
                        if !showAns {
                            Text("Tap to reveal the answers.")
                                .foregroundColor(.gray)
                        }
                        
                        Text("Current score: \(Int(currentScore))")
                            .font(.headline)
                    }
                }
                .scrollContentBackground(.hidden)  // <--- Remove default list background
                .background(Color.clear)
                .navigationTitle("Multiplication")
                .foregroundStyle(.black)
                .toolbar {
                    Button("New Game") {
                        startGame()
                    }
                }
                .onAppear {
                    generateQuestion()
                }
                .onChange(of: number){ _ in
                    generateQuestion()
                }
                .onChange(of: noOfQuestion){ _ in
                    generateQuestion()
                }
                
                .alert(scoreTitle, isPresented: $showingScore) {
                    Button("Continue", role: .cancel) {
                        // If you want something to happen on dismiss
                    }
                }
                .alert("Game over",isPresented:$resetFlag){
                    Button("Reset",action:startGame)
                } message:{
                    Text("Your score is \(Int(currentScore)).")
                }
            }
            
        }
        
    
    }
}

#Preview {
    ContentView()
}
