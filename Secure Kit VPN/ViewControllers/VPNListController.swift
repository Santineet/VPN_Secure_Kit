//
//  VPNListController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 20.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class VPNListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate{
    public var didSelectVpn: (() -> Void)?
    @IBOutlet weak var segmentedBlockConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var favoriteSegmentedIndex: Int = 0
    private var standardSegmentedIndex: Int = 1
    private var doubleSegmentedIndex: Int = 2
    
    private var searchedVpnList: [VpnEntity] = []
    
    private var isSearch = false{
        didSet{
            //fav = DataManager.getFavoriteVpnList().sorted(by: { $0.name! < $1.name! })
            searchedVpnList = totalVpnList
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchController.dismiss(animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            searchedVpnList = totalVpnList
        }
        else{
            searchedVpnList = totalVpnList.filter({ $0.filteredName!.lowercased().contains(searchText.lowercased()) })
        }
        self.tableView.reloadData()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("Dismissed!")
        isSearch = false
        segmentedBlockConstraint.constant = 64.0
        segmentedControl.isHidden = false
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        print("Presented!")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch{
            return 1
        }
        return segmentedControl.selectedSegmentIndex == doubleSegmentedIndex ? doubleVpnList.count : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch{
            return searchedVpnList.count
        }
        return segmentedControl.selectedSegmentIndex != doubleSegmentedIndex ? currentVpnList.count : !doubleVpnList[section].opened ? 0 : doubleVpnList[section].vpnList.count
    }
    
    @IBAction func changedSegmenetedControl(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == favoriteSegmentedIndex{
            initFavoriteVpn()
        }
        else if segmentedControl.selectedSegmentIndex == standardSegmentedIndex{
            initStandartVpn()
        }
        else if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
            initDoubleVpn()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var currentVpnList: [VpnEntity] = []
    private var doubleVpnList: [DoubleVpnSection] = []
    private var totalVpnList: [VpnEntity] = DataManager.getVpnList()
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearch{
            return nil
        }
        if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
            if section == 0{
                return nil
            }
            let header: VpnHeader = VpnHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0))
            header.sectionLabel.text = doubleVpnList[section].name
            header.onClick = {
                self.doubleVpnList[section].opened = !self.doubleVpnList[section].opened
                self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearch{
            return .leastNormalMagnitude
        }
        return segmentedControl.selectedSegmentIndex == doubleSegmentedIndex ? (section == 0 ? .leastNormalMagnitude : 50.0) : .leastNormalMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
            let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1.0))
            v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
            return v
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return segmentedControl.selectedSegmentIndex == doubleSegmentedIndex ? (doubleVpnList[section].opened ? .leastNormalMagnitude : 0.5) : .leastNormalMagnitude
    }
    
    var searchController = UISearchController(searchResultsController: nil)
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isSearch{
            self.searchController.dismissKeyboard()
        }
        print("Begin scrolled!")
    }
    
    @IBAction func onSearch(_ sender: Any) {
        segmentedControl.isHidden = true
        segmentedBlockConstraint.constant = 10.0
        isSearch = true
        self.present(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "VpnCell", bundle: nil), forCellReuseIdentifier: "VpnCell")
        let hasStandardVpn: Bool = DataManager.getVpnList().filter({ $0.group! == "1" }).count != 0
        let hasDoubleVpn: Bool = DataManager.getVpnList().filter({ $0.group! == "2" }).count != 0
        if hasStandardVpn{
            initStandartVpn()
        }
        else{
            segmentedControl.removeSegment(at: 1, animated: false)
            doubleSegmentedIndex = 1
            standardSegmentedIndex = 2
            initDoubleVpn()
        }
        if !hasDoubleVpn{
            segmentedControl.removeSegment(at: 2, animated: false)
        }
        segmentedControl.selectedSegmentIndex = DataManager.getFavoriteVpnList().count == 0 ? 1 : 0
        if segmentedControl.selectedSegmentIndex == 0{
            initFavoriteVpn()
        }
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 55, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.ensureiOS12Style()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.hidesBottomBarWhenPushed = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor(rgb: 0x33a5db)
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor(rgb: 0x33a5db).cgColor
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        /*let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white

        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.white*/
        searchController.searchBar.getTextField()?.textColor = .white
        searchController.searchBar.getTextField()?.placeholder = nil
        searchController.searchBar.getTextField()?.attributedPlaceholder = NSAttributedString(string: "Search".localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        searchController.searchBar.setImage(UIImage(named: "Clear"), for: .clear, state: .normal)
        searchController.searchBar.setPlaceholder(textColor: .white)
        if let leftView = searchController.searchBar.getTextField()?.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = UIColor.white
        }
        
        if let rightView = searchController.searchBar.getTextField()?.rightView as? UIImageView {
            rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
            rightView.tintColor = UIColor.white
        }
        /*if let clearButton = searchController.searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            print("CLEAR BUTTON")
           // Create a template copy of the original button image
            if let img3 = clearButton.image(for: .highlighted){
                let templateImage =  img3.withRenderingMode(.alwaysTemplate).imageWithColor(color1: .white)
                clearButton.setImage(templateImage, for: .normal)
                clearButton.setImage(templateImage, for: .highlighted)
            }
           // Set the template image copy as the button image
           // Finally, set the image color
        }*/
        searchController.searchBar.showsCancelButton = true
        searchController.delegate = self
        self.totalVpnList = totalVpnList.filter({ $0.group! == "1" }).sorted(by: { $0.name! < $1.name! }) + totalVpnList.filter({ $0.group! == "2" }).sorted(by: { $0.name! < $1.name! })
        self.searchedVpnList = totalVpnList
    }
    
    private func initStandartVpn(){
        currentVpnList = totalVpnList.filter({ $0.group! == "1" }).sorted(by: { $0.name! < $1.name! })
        self.tableView.reloadData()
    }
    
    private func initDoubleVpn(){
        let doubleVpn = totalVpnList.filter({ $0.group! == "2" }).sorted(by: { $0.name! < $1.name! })
        doubleVpnList.removeAll()
        doubleVpnList.append(DoubleVpnSection(name: "fas", vpnList: [], opened: false))
        for vpn in doubleVpn{
            let sectionName: String = "Double " + vpn.name!.components(separatedBy: "-")[0]
            if doubleVpnList.filter({ $0.name == sectionName }).count == 0{
                doubleVpnList.append(DoubleVpnSection(name: sectionName, vpnList: [], opened: false))
                doubleVpnList.filter({ $0.name == sectionName })[0].addVpn(vpn)
            }
            else{
                doubleVpnList.filter({ $0.name == sectionName })[0].addVpn(vpn)
            }
        }
        self.tableView.reloadData()
    }
    
    private func initFavoriteVpn(){
        currentVpnList = DataManager.getFavoriteVpnList().sorted(by: { $0.name! < $1.name! })
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VpnCell = tableView.dequeueReusableCell(withIdentifier: "VpnCell") as! VpnCell
        //cell.showSeparator()
        if isSearch{
            cell.initData(searchedVpnList[indexPath.row])
        }
        else{
            cell.initData(segmentedControl.selectedSegmentIndex == doubleSegmentedIndex ? doubleVpnList[indexPath.section].vpnList[indexPath.row] : currentVpnList[indexPath.row])
            if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
                if !doubleVpnList[indexPath.section].opened{
                    //cell.hideSeparator()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearch{
            return 50.0
        }
        if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
            if indexPath.section == 0{
                return 0.0
            }
            return doubleVpnList[indexPath.section].opened ? 50.0 : 0.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearch{
            DataManager.saveLastVpn(searchedVpnList[indexPath.row])
        }
        else if segmentedControl.selectedSegmentIndex == doubleSegmentedIndex{
            DataManager.saveLastVpn(doubleVpnList[indexPath.section].vpnList[indexPath.row])
        }
        else{
            DataManager.saveLastVpn(currentVpnList[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
        self.didSelectVpn!()
    }
}

public class DoubleVpnSection{
    var name: String
    var vpnList: [VpnEntity]
    var opened: Bool
    
    
    init(name: String, vpnList: [VpnEntity], opened: Bool){
        self.name = name
        self.vpnList = vpnList
        self.opened = opened
    }
    
    func addVpn(_ vpn: VpnEntity){
        vpn.filteredName = vpn.filteredName!.replacingOccurrences(of: "Double", with: "")
        vpnList.append(vpn)
    }
}
