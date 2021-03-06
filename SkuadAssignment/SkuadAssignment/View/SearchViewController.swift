//
//  SearchViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchTextField: UITextField!
    
    var searchViewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search for images"
        searchViewModel = SearchViewModel()
        searchViewModel?.reloadTableView = tableView?.reloadData
        searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func searchButtonTapped() {
        if !(searchTextField.text?.isEmpty ?? true) {
            let searchResultViewModel = ImageSearchResultViewModel(searchTextField.text ?? "", { [weak self] in
                self?.searchViewModel?.addToLRU(self?.searchTextField.text ?? "")
            })
            navigationController?.pushViewController(ImageSearchResultViewController.viewController(searchResultViewModel), animated: true)
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableView Datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel?.queries.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewIdentifier") {
            cell.textLabel?.text = searchViewModel?.queries[indexPath.row] ?? ""
            cell.textLabel?.textColor = UIColor.gray
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewIdentifier")
            cell.textLabel?.text = searchViewModel?.queries[indexPath.row] ?? ""
            cell.textLabel?.textColor = UIColor.gray
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchViewModel?.headerTitle
    }
    
    // MARK: - UITableView Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchViewModel = searchViewModel {
            let searchResultViewModel = ImageSearchResultViewModel(searchViewModel.queries[indexPath.row], { [weak self] in
                self?.searchViewModel?.addToLRU(self?.searchViewModel?.queries[indexPath.row] ?? "")
            })
            navigationController?.pushViewController(ImageSearchResultViewController.viewController(searchResultViewModel), animated: true)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    // MARK: - UITextField Delegate methods
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        searchViewModel?.textFieldDidChange()
    }
}
