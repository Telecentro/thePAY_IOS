//
//  SNSListCollectionView.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/10.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class SNSListCollectionViewCell: UICollectionViewCell {
    enum SNSType: String {
        case tell = "0"
        case schema = "1"
        case moveLink = "2"
    }
    
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var ivIcon: UIImageView!
}

class ColumnFlowLayout: UICollectionViewFlowLayout {

    let cellsPerRow: Int
    let height: CGFloat
    init(cellsPerRow: Int, height: CGFloat, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        self.height = height
        super.init()

        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: height)
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}

class SNSListCollectionView: UICollectionView {
    
    var moveSNSList: ((SubPreloadingResponse.snsList)->())?
    var data:[SubPreloadingResponse.snsList]?
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
        height: 64,
        minimumInteritemSpacing: 7,
        minimumLineSpacing: 7,
        sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.collectionViewLayout = columnLayout
        self.delegate = self
        self.dataSource = self
    }
}

extension SNSListCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SNSListCollectionViewCell
        if let item = data?[exist: indexPath.row] {
            cell.lblTitle.text = item.text
            if let imgUrlString = item.iconUrl, let imgUrl = URL(string: imgUrlString) {
                cell.ivIcon.kf.setImage(with: imgUrl)
            }
        }
        cell.backgroundView = UIImageView(image: UIImage(named: "input_box_44_44"))
        cell.selectedBackgroundView = UIImageView(image: UIImage(named: "select_44"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = data?[exist: indexPath.row] else { return }
        moveSNSList?(item)
    }
}
