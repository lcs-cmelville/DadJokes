//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: Stored Properties
    
    // Detect when an app  moves between foreground, background, and inactive states
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentJoke: DadJoke = DadJoke(id: "",
                                              joke: "Knock knock...",
                                              status: 0)
    // This will keep track of our list of favourite jokes
    @State var favourites: [DadJoke] = []   // enpty list to start
    
    // This will let us know whether the current joke exists as a favourite
    @State var currentJokeAddedToFavourites: Bool = false
    
    //MARK: Computed Properties
    var body: some View {
        VStack {
            
            Text(currentJoke.joke)
                .multilineTextAlignment(.center)
                .font(.title)
                .minimumScaleFactor(0.5)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .foregroundColor(currentJokeAddedToFavourites == true ? .red : .secondary)
                .font(.largeTitle)
                .padding(.bottom)
                .onTapGesture {
                    
                    // Only add to the list if it isn't already there
                    if currentJokeAddedToFavourites == false {
                        
                        // Adds the surrent joke to the list
                        favourites.append(currentJoke)
                        
                        // Record that we have marked this as a favourite
                        currentJokeAddedToFavourites = true
                        
                    }
                }
            
            Button(action: {
                
                // The Task type allows us to run asynchronous code within a button, and have the user interface be undated when the data is ready.
                // Since it is asynchronous, other tasks can run while we wait for the data to come back from the web server
                Task {
                    // Call the function that will load a new joke
                    await loadNewJoke()
                }
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack{
                
                Text("Favourites")
                    .bold()
                    .multilineTextAlignment(.leading)
                    .font(.title3)
                    .padding()
                
                Spacer()
            }
            
            // Iterate over the list of favourites
            // As we iterate, each individual favourite is accessible via "currentFavourte"
            List(favourites, id: \.self) { currentFavourite in
                Text(currentFavourite.joke)
            }
            
            Spacer()
            
        }
        // When the app opens, get a new joke from the web service
        .task {
            
            // Load a joke from the endpoint. We are "calling"/"invoking" the function named "loadNewJoke"
            // A term for this is the "call site" of a function
            // This just means that we as the programmer, are aware that this function is asynchronous.
            // Result might come right away, or take some time to compltete. ALSO: Any code below this call will run before the function call completes.
            await loadNewJoke()
            
            print("I tried to load a new joke")
            
        }
        
        // React to changes of state for the app, foreground, background, and inactive
        .onChange(of: scenePhase) { newPhase in
           
            if newPhase == .inactive{
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
            } else {
                print("Background")
                
                // Permanently save the list of tasks
                persistFavourites()
            }
            
        }
        .navigationTitle("icanhazdadjoke?")
        .padding()
    }
    
    //MARK: Functions
    
    // Define the function "loadNewJoke". Teaching our app to do a new thing
    // Using the "async" keyword means that this function can potentially be run alongside other tasks the app needs to do
    func loadNewJoke() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
            // Reset the flag that tracks whether the current joke is a favourite
            currentJokeAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
    }
    
    // To save the data permanently
    func persistFavourites() {
        
        // Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        // Try to encode the data in our list of favourites  JSON
        
        do {
            
            // Create a JSON encoder object
            let  encoder = JSONEncoder()
           
            // Configured the coder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of Favourites we collected
            let data = try encoder.encode(favourites)
            
            // rite the JSON to a file in the fineName location we came up with earlier
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Save data to the Documetns directory successfully")
            print("========")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            print("Unable to write list of favourites to the Document directory")
            print("========")
            print(error.localizedDescription)
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
