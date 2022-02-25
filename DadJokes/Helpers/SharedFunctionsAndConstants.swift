//
//  SharedFunctionsAndConstants.swift
//  DadJokes
//
//  Created by Claire Coding Account on 2022-02-25.
//

import Foundation

// To return the location of the Documents directery for the app
func getDocumentsDirectory() -> URL {
    
    let paths = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
    
    // Return the first path
    return paths[0]
    
}

// Define a finename (label)  that we will write the data to in the directory
let savedFavouritesLabel = "savedFavourites"
