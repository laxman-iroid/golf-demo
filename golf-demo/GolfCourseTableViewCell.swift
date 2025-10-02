import UIKit

class GolfCourseTableViewCell: UITableViewCell {
    
    private var courseNameLabel: UILabel!
    private var clubNameLabel: UILabel!
    private var locationLabel: UILabel!
    private var detailsLabel: UILabel!
    private var containerView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Container view for card-like appearance
        containerView = UIView()
        containerView.backgroundColor = UIColor.secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Course name label (main title)
        courseNameLabel = UILabel()
        courseNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        courseNameLabel.textColor = UIColor.label
        courseNameLabel.numberOfLines = 1
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Club name label (subtitle)
        clubNameLabel = UILabel()
        clubNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        clubNameLabel.textColor = UIColor.secondaryLabel
        clubNameLabel.numberOfLines = 1
        clubNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Location label
        locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = UIColor.tertiaryLabel
        locationLabel.numberOfLines = 1
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Details label (tee info, par, etc.)
        detailsLabel = UILabel()
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = UIColor.systemBlue
        detailsLabel.numberOfLines = 2
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(courseNameLabel)
        containerView.addSubview(clubNameLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(detailsLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Course name label
            courseNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            courseNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Club name label
            clubNameLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            clubNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            clubNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Location label
            locationLabel.topAnchor.constraint(equalTo: clubNameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: detailsLabel.leadingAnchor, constant: -8),
            
            // Details label
            detailsLabel.topAnchor.constraint(equalTo: clubNameLabel.bottomAnchor, constant: 4),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            detailsLabel.widthAnchor.constraint(equalToConstant: 100),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Add selection style
        selectionStyle = .none
    }
    
    func configure(with course: GolfCourse) {
        courseNameLabel.text = course.courseName
        clubNameLabel.text = course.clubName
        locationLabel.text = "\(course.location.city), \(course.location.state)"
        
        // Configure details based on available tee information
        var detailsText = ""
        if let tees = course.tees, let maleTees = tees.male, !maleTees.isEmpty {
            let teeBox = maleTees[0]
            detailsText = "\(teeBox.numberOfHoles) holes\nPar \(teeBox.parTotal)"
            
            if let holes = teeBox.holes, !holes.isEmpty {
                let firstHole = holes[0]
                detailsText += "\nNext: Par \(firstHole.par)"
            }
        } else {
            detailsText = "Golf Course\nTap to view"
        }
        
        detailsLabel.text = detailsText
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.backgroundColor = highlighted ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.containerView.transform = .identity
                }
            }
        }
    }
}