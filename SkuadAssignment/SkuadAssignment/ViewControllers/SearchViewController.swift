//
//  SearchViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchTextField: UITextField!
    
    var queries = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewIdentifier") {
            cell.textLabel?.text = queries[indexPath.row]
            return cell
        }
        else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewIdentifier")
            cell.textLabel?.text = queries[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ImageSearchViewController.viewController(queries[indexPath.row], { [weak self] in
            self?.addToLRU(self?.queries[indexPath.row] ?? "")
        }), animated: true)
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        let arr = getFromLRU()
        queries = arr
        tableView.reloadData()
    }
    
    private func addToLRU(_ text: String) {
        LRUCache.sharedInstance.put(text, text)
    }
    
    private func getFromLRU() -> [String] {
        return LRUCache.sharedInstance.get()
    }
    
    @IBAction func searchButtonTapped() {
        navigationController?.pushViewController(ImageSearchViewController.viewController(searchTextField.text ?? "", { [weak self] in
            self?.addToLRU(self?.searchTextField.text ?? "")
        }), animated: true)
    }
    
}
