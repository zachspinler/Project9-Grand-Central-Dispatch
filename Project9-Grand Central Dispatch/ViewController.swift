//
//  ViewController.swift
//  Project9-Grand Central Dispatch
//
//  Created by Zach Spinler on 4/7/20.
//  Copyright © 2020 Zach Spinler. All rights reserved.
//

import UIKit

// Challenge 2: add Search Bar functionality
class ViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var petitions = [Petition]()
    var searchedPetitions = [Petition]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Petitions"
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        title = "Whitehouse Petitions"
        // Challenge 1 -- add Credits button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsAlert))
}
    
   @objc func creditsAlert() {
        let ac = UIAlertController(title: nil, message: "This data comes from We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    // Search function
   @objc func search() {
        
        guard let searchBarText = searchController.searchBar.text?.lowercased() else { return }
        
        if searchBarText.isEmpty {
            searchedPetitions = petitions
        } else {
            searchedPetitions = petitions.filter { $0.title.lowercased().contains(searchBarText) }
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func fetchJSON() {
    
                var urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        //        var urlString = "https://www.hackingwith  swift.com/samples/petitions-1.json"
                
            if navigationController?.tabBarItem.tag == 0 {
                     urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        //            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
                } else {
                     urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        //            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
                }
            
                if let url = URL(string: urlString) {
                    if let data = try? Data(contentsOf: url)
                    {
                        // we're okay to parse
                        parse(json: data)
                        performSelector(onMainThread: #selector(search), with: nil, waitUntilDone: false)
                        return
                }
            }
        }
    
        
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try?
            decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            //Set the tableview on the main thread
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let petition = searchedPetitions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = searchedPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }


func updateSearchResults(for searchController: UISearchController) {
        search()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search()
    }
}
