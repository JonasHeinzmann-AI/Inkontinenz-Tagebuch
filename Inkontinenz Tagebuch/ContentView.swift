import SwiftUI

struct ContentView: View {
    @State private var selectedEntryType: EntryType = .food
    @State private var rememberedFoods: [String] = [] // Remembered food items
    @State private var rememberedDrinks: [String] = [] // Remembered drink items
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Healthy Habits")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black) // Changed to black
                .padding(.top, 20)
            
            // Entry Type Selector
            Picker("Select Entry Type", selection: $selectedEntryType) {
                ForEach(EntryType.allCases, id: \.self) { entryType in
                    Text(entryType.rawValue.capitalized)
                        .tag(entryType)
                        .foregroundColor(.black) // Changed to black
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Selected Entry Form
            switch selectedEntryType {
            case .food:
                FoodEntryForm(rememberedFoods: $rememberedFoods)
            case .drink:
                DrinkEntryForm(rememberedDrinks: $rememberedDrinks)
            case .toilet:
                ToiletEntryForm()
            }
            
            Spacer()
            
            // Footer
            Text("Made with ❤️ by Jonas Heinzmann")
                .foregroundColor(.black) // Changed to black
                .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white) // Changed background to white
        .edgesIgnoringSafeArea(.all)
    }
}

struct FoodEntryForm: View {
    @Binding var rememberedFoods: [String]
    @State private var eatenFood: String = ""
    @State private var eatenTime = Date()
    @State private var foodAmount: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "applelogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                TextField("What did you eat?", text: $eatenFood)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                Button(action: {
                    if !eatenFood.isEmpty {
                        rememberedFoods.append(eatenFood)
                        eatenFood = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            Picker("Remembered Foods", selection: $eatenFood) {
                ForEach(rememberedFoods, id: \.self) { food in
                    Text(food)
                        .foregroundColor(.black) // Changed to black
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("How much did you eat?", text: $foodAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
            
            DatePicker("When did you eat?", selection: $eatenTime, displayedComponents: .hourAndMinute)
                .foregroundColor(.black)
            
            Button(action: {
                DatabaseManager.shared.saveEaten(food: self.eatenFood, food_amount: self.foodAmount, eatenAt: self.eatenTime)
            }) {
                Text("Send Food Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // Changed background to light gray
        .cornerRadius(10)
    }
}

struct DrinkEntryForm: View {
    @Binding var rememberedDrinks: [String]
    @State private var drank: String = ""
    @State private var drinkAmount: String = ""
    @State private var drankTime = Date()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "drop")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                TextField("What did you drink?", text: $drank)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                Button(action: {
                    if !drank.isEmpty {
                        rememberedDrinks.append(drank)
                        drank = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            Picker("Remembered Drinks", selection: $drank) {
                ForEach(rememberedDrinks, id: \.self) { drink in
                    Text(drink)
                        .foregroundColor(.black) // Changed to black
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("How much did you drink?", text: $drinkAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
            
            DatePicker("When did you drink?", selection: $drankTime, displayedComponents: .hourAndMinute)
                .foregroundColor(.black)
            
            Button(action: {
                DatabaseManager.shared.saveDrunk(drink: self.drank, amount: self.drinkAmount, drunkAt: self.drankTime)
            }) {
                Text("Send Drink Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // Changed background to light gray
        .cornerRadius(10)
    }
}

struct ToiletEntryForm: View {
    @State private var selectedAction = "Poop"
    @State private var toiletTime = Date()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Picker("Select action", selection: $selectedAction) {
                    Text("Poop").tag("Poop")
                    Text("Pee").tag("Pee")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            DatePicker("When did you take the action?", selection: $toiletTime, displayedComponents: .hourAndMinute)
                .foregroundColor(.black)
            
            Button(action: {
                DatabaseManager.shared.saveToilet(action: self.selectedAction, time: self.toiletTime)
            }) {
                Text("Send Toilet Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // Changed background to light gray
        .cornerRadius(10)
    }
}

enum EntryType: String, CaseIterable {
    case food
    case drink
    case toilet
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let webhookURL = "https://neuralmediclookbook-25w87d6g.b4a.run/data/" // Webhook URL
    
    private init() {}
    
    // Methods to save data to the webhook
    func saveEaten(food: String, food_amount: String, eatenAt: Date) {
        sendDataToWebhook(data: ["food": food, "food_amount": food_amount, "eatenAt": eatenAt.description, "type":"food"])
    }
    
    func saveDrunk(drink: String, amount: String, drunkAt: Date) {
        sendDataToWebhook(data: ["drink": drink, "amount": amount, "drunkAt": drunkAt.description, "type":"drink"])
    }
    
    func saveToilet(action: String, time: Date) {
        sendDataToWebhook(data: ["action": action, "time": time.description, "type":"toilet"])
    }
    
    private func sendDataToWebhook(data: [String: Any]) {
        guard let url = URL(string: webhookURL) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    print("Failed to send data: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Data sent successfully.")
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
                }
            }
            
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}
