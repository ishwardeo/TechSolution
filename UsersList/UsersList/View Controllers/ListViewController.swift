//
//  ListViewController.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import UIKit

enum FilterOptions: String {
    case male
    case female
}

enum SortOptions: String {
    case ascending
    case descending
}

class ListViewController: UIViewController {
    @IBOutlet weak var filterPickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var defaultPickerOptions = [FilterOptions.male.rawValue, FilterOptions.female.rawValue] // default
    var selectedOption = "male" // default
    
    var viewModel = UserListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureScreenLayout()
    }
}

//MARK: - Screen Layout methods

extension ListViewController {
    fileprivate func configureScreenLayout() {
        self.navigationItem.title = GlobalConstants.USER_LIST
        setupFilterBtn()
        setupSortBtn()
        
        viewModel.deleteAll()
        layoutTableView()
        setupClosures()
        fetchOrLoadLocalData()
    }
    
    private func layoutTableView() {
        filterPickerView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        tableView.refreshControl = UIRefreshControl()
        
        tableView.refreshControl?.addTarget(self, action: #selector(refreshUserList), for: .valueChanged)
    }
    
    @objc private func refreshUserList() {
        viewModel.deleteAll()
        viewModel.getListData()
    }
    
    private func setupClosures() {
        viewModel.reloadList = { [weak self] () in
            // Use Main thread to update UI
            DispatchQueue.main.async {
                self?.tableView.alpha = 1.0
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.errorMessage = { [weak self] (message) in
            // Use Main thread to update UI
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.tableView.alpha = 1.0
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func fetchOrLoadLocalData() {
        let isFetched = UserDefaults.standard.value(forKey: GlobalConstants.DATA_ALREADY_DOWNLOADED) as? Bool
        if (isFetched == nil) || !(isFetched ?? false){
             activityIndicator.startAnimating()
            ///API calling from viewmodel class
            viewModel.getListData()
        } else {
            viewModel.fetchLocalData()
        }
    }
    
    private func setupFilterBtn() {
        let button = UIButton(type: .custom)
        button.setTitle("Sort", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        
        //add function for button
        button.addTarget(self, action: #selector(sortBtnAction), for: .touchUpInside)
        
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)

        let barButton = UIBarButtonItem(customView: button)
        
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func sortBtnAction() {
        filterPickerView.isHidden = false
        tableView.alpha = 0.0
        defaultPickerOptions = [SortOptions.ascending.rawValue, SortOptions.descending.rawValue]
        filterPickerView.reloadAllComponents()
    }
    
    private func setupSortBtn() {
        let button = UIButton(type: .custom)
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(.red, for: .normal)
        
        //add function for button
        button.addTarget(self, action: #selector(filterBtnAction), for: .touchUpInside)
        
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)

        let barButton = UIBarButtonItem(customView: button)
        
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func filterBtnAction() {
        filterPickerView.isHidden = false
        tableView.alpha = 0.0
        defaultPickerOptions = [FilterOptions.male.rawValue, FilterOptions.female.rawValue]
        filterPickerView.reloadAllComponents()
    }
    
    private func displayListAfterSortAndFilter(sortOrderOrFilterText text: String) {
        switch text {
            case SortOptions.ascending.rawValue, SortOptions.descending.rawValue:
                viewModel.sortInOrder(sortOrder: SortOptions.init(rawValue: text) ?? SortOptions.ascending)
            default:
                viewModel.filterGender(filterText: FilterOptions.init(rawValue: text) ?? FilterOptions.male)
        }
    }
}

//MARK: - Picker View Datasource methods

extension ListViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return defaultPickerOptions.count
    }
}

//MARK: - Picker View Delegate methods

extension ListViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < defaultPickerOptions.count {
            let title = defaultPickerOptions[row]
            return title
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < defaultPickerOptions.count {
            selectedOption = defaultPickerOptions[row]
            pickerView.isHidden = true
            
            displayListAfterSortAndFilter(sortOrderOrFilterText: selectedOption)
        }
    }
}

//MARK: - Datasource methods

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayOfList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing : ReusableTableViewCells.self), for: indexPath) as? ReusableTableViewCells else {
            return UITableViewCell()
        }

        let listObj = viewModel.arrayOfList[indexPath.row]
        ///Cell data settings
        cell.nameLabel.text = listObj.name
        cell.idLabel.text = "id: " + (listObj.id ?? "")
        cell.sexLabel.text = listObj.gender
        cell.ageLabel.text = "Age: " + String(listObj.age)

        viewModel.downloadImage(urlString: listObj.avatar) { (image) in
            DispatchQueue.main.async {
                cell.avatarImgView.image = image
            }
        }
        
        ///cell background color change
        if ((indexPath.row % 2) != 0){
            cell.contentView.backgroundColor = UIColor.lightGray
        } else {
            cell.contentView.backgroundColor = UIColor.clear
        }
        return cell
    }
}

//MARK: - Delegate methods

extension ListViewController: UITableViewDelegate {

}

