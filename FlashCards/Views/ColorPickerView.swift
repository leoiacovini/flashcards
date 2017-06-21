//
//  ColorPickerView.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import SnapKit

class ColorPickerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "ColorPickerCollectionViewCell"
    lazy private var checkMark: UIImageView! = {
        let cm = UIImageView(image: #imageLiteral(resourceName: "check"))
        cm.contentMode = .scaleAspectFit
        cm.isHidden = true
        return cm
    }()
    
    var color: UIColor! {
        didSet {
            self.backgroundColor = self.color
            self.layer.cornerRadius = self.bounds.width / 2
        }
    }
    
    var checked: Bool = false {
        didSet {
            if checked {
                UIView.transition(with: self, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.backgroundView = UIImageView(image: UIImage(contentsOfFile: "check"))
                    self.layer.borderColor = UIColor.black.cgColor
                    self.layer.borderWidth = 1
                    self.checkMark.isHidden = false
                }, completion: nil)
            } else {
                self.layer.borderWidth = 0
                self.checkMark.isHidden = true
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(checkMark)
        checkMark.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        }
    }
    
}

protocol ColorPickerViewDelegate: class {
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt: IndexPath) -> Void
}

class ColorPickerView: UIView {
    
    lazy var collectionView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(ColorPickerCollectionViewCell.self, forCellWithReuseIdentifier: ColorPickerCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    public var colors: Array<UIColor> = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.3835619448, blue: 0.3644898282, alpha: 1), #colorLiteral(red: 0.9836628946, green: 1, blue: 0.1662727548, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1), #colorLiteral(red: 0.5612005245, green: 0.3096122621, blue: 1, alpha: 1), #colorLiteral(red: 0.3140794347, green: 1, blue: 0.8784005545, alpha: 1), #colorLiteral(red: 0.628577967, green: 1, blue: 0.1056284226, alpha: 1)]
    public weak var delegate: ColorPickerViewDelegate?
    
    public var selectedColorIndex: Int? {
        didSet {
            if let colorPickerCell = collectionView.cellForItem(at: IndexPath(item: selectedColorIndex!, section: 0)) as? ColorPickerCollectionViewCell {
                if let itemIndex = oldValue,
                   let previousSelectedCell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: 0)) as? ColorPickerCollectionViewCell {
                    previousSelectedCell.checked = false
                }
                colorPickerCell.checked = true
            }
        }
    }
    
    public var selectedColor: UIColor? {
        get {
            return selectedColorIndex != nil ? colors[selectedColorIndex!] : nil
        }
        set {
            for (index, color) in colors.enumerated() where color.hexValue == newValue?.hexValue {
                self.selectedColorIndex = index
            }
        }
    }
    
    override func layoutSubviews() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

extension ColorPickerView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPickerCollectionViewCell.reuseIdentifier, for: indexPath) as! ColorPickerCollectionViewCell
        if indexPath.item == selectedColorIndex {
            cell.checked = true
        } else {
            cell.checked = false
        }
        cell.color = colors[indexPath.item]
        return cell
    }
    
}


extension ColorPickerView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColorIndex = indexPath.item
        delegate?.colorPickerView(self, didSelectItemAt: indexPath)
    }
    
    
}

extension ColorPickerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
}
