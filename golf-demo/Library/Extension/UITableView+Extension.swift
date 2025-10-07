//
//  UITableView+Extension.swift
//  TransportationManagement
//
//  Created by iroid on 23/09/21.
//

import Foundation
import UIKit

extension UITableView {

    func scrollToBottom(isAnimated:Bool = true){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }

    func scrollToTop(isAnimated:Bool = true) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func setEmptyDataMessage(data:Int,text:String) -> Int{
        print(data)
        var numOfSections:Int = 0
        if data > 0 {
            numOfSections = data
            self.backgroundView = nil
        } else {
            let noDataView = UIView(frame: CGRect(x: 0, y: 0 , width: self.bounds.size.width, height: self.bounds.size.height))
            let noDataLabel = UILabel(frame: CGRect(x: 15, y: self.bounds.size.height/2 - 30, width: self.bounds.size.width - 30, height: 80))
            noDataLabel.text = text
            noDataLabel.font = themeFont(size: 15, fontname: .regular)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataView.addSubview(noDataLabel)
            self.backgroundView = noDataView
        }
        return numOfSections
    }
    
    func showNoDataLabel(_ strAltMsg: String, isScrollable: Bool)
    {
        let noDataView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let msglbl           = UILabel(frame: CGRect(x: 12, y: 25, width: self.bounds.size.width-24, height: self.bounds.size.height-50))
        msglbl.text          = strAltMsg
        msglbl.textAlignment = .center
        msglbl.font          = UIFont(name: "LexendDeca-Medium", size: 16.0)
        msglbl.numberOfLines = 0
        msglbl.textColor     = #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1) //UIColor(white: 0.9, alpha: 1.0)
        
        msglbl.translatesAutoresizingMaskIntoConstraints = true
        
        noDataView.addSubview(msglbl)
        noDataView.translatesAutoresizingMaskIntoConstraints = true
        
        self.isScrollEnabled = isScrollable
        self.backgroundView  = noDataView
    }
    
    func removeNoDataLabel()
    {
        self.isScrollEnabled = true
        self.backgroundView  = nil
    }
    
}
