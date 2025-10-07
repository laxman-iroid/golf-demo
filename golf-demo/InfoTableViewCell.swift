//
//  InfoTableViewCell.swift
//  golf-demo
//
//  Created by Laxman Rajpurohit on 07/10/25.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        
        numberLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        numberLabel.textColor = .black
    }
    
    func configure(title: String, number: String) {
        titleLabel.text = title
        numberLabel.text = number
    }
}
