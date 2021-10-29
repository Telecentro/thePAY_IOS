//
//  NoticeViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class NoticeCell: UITableViewCell {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDate: TPLabel!
    
}

class NoticeViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var noticeTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var lblNavTitle: TPLabel!
    
    var searchConditions = ["1", "7", "15", "30"]
    var lastSelectRow = 0
    var selectRow = 0
    var dataList: [PushHistoryResponse.O_DATA.pushList]?
    
    private var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .white
        return picker
    } ()
    
    private var toolBar: UIToolbar = {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.backgroundColor = UIColor(named: "Primary")
        
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([cancel, flexibleSpace, done], animated: false)
        
        done.tintColor = .white
        cancel.tintColor = .white
        return toolbar
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        lblNavTitle.text = Localized.btn_search_setting.txt
        let selectedColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        segment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segment.setTitleTextAttributes(selectedColor, for: .selected)
    }
    
    func initialize() {
        self.picker.dataSource = self
        self.picker.delegate = self
        self.noticeTableView.delegate = self
        self.noticeTableView.dataSource = self
        reqNotice(row: 0)
    }
    
    @IBAction func switchValue(_ sender: UISegmentedControl) {
        reqNotice(row: sender.selectedSegmentIndex)
    }
    
    @IBAction func refresh(_ sender: Any) {
        reqNotice(row: self.segment.selectedSegmentIndex)
    }
    
    
    func reqNotice(row: Int) {
        let req = PushHistoryRequest(param: PushHistoryRequest.Param(day: searchConditions[row]))
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<PushHistoryResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.dataList = data.O_DATA?.pushList
                self.noticeTableView.reloadData()
                print("success: \(data)")
                self.hideLoadingWindow()
            case .failure(let error):
                error.processError(target: self)
                self.hideLoadingWindow()
            }
        }
    }
    
    
    // 조건검색 버튼
    @IBAction func searchSetting(_ sender: Any) {
        picker.selectRow(self.selectRow, inComponent: 0, animated: true)
    }
    
}

extension NoticeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as! NoticeCell
        if let data = self.dataList?[indexPath.row] {
            let html = data.pushData?.content?.replacingOccurrences(of: "</br>", with: " ")
            cell.lblTitle.attributedText = html?.convertHtml(fontSize: 14)
            cell.lblDate.text = data.pushDay
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let data = self.dataList else { return }
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "TextViewController") as? TextViewController else { return }
        vc.titleString = Localized.title_activity_notice.txt
        vc.contents = data[indexPath.row].pushData?.content
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension NoticeViewController {
    // 피커 선택 버튼
    @objc private func pressDone() {
        self.lastSelectRow = self.selectRow
        reqNotice(row: self.selectRow)
    }
    
    // 피커 취소 버튼
    @objc private func pressCancel() {
        self.selectRow = self.lastSelectRow
    }
}

extension NoticeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return searchConditions.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectRow = row
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return searchConditions[row] + " " + "Day"
    }
}
