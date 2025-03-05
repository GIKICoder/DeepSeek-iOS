//
//  ChatInputFloatPhotoView.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/27.
//

import UIKit
import AppFoundation
import SnapKit

@MainActor
class ChatInputFloatPhotoView: UIView {
    
    // MARK: - Public Properties
    
    var onPhotoTap: (() -> Void)?
    var onCloseButtonTap: (() -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(hex: "f0f0f0")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_photo_close_ic"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: ProgressView = {
        let pv = ProgressView(.white.withAlphaComponent(0.5))
        pv.progressColor = .white
        return pv
    }()
    
    // 进度视图容器
    private lazy var progressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    /// 上传状态视图容器
    private lazy var succeedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var failedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var failedLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.text = "Retry".localized
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    
    public func setImage(_ image: UIImage?) {
        photoImageView.image = image
    }
    
    // 更新进度的API
    public func updateProgress(_ progress: CGFloat) {
        progressContainer.isHidden = false
        progressView.isHidden = false
        removeLiveIconFailed(failedView)
        let progressV2 = min(0.99, progress)
        progressView.setProgress(progressV2)
        progressContainer.isHidden = progress <= 0
    }
    
    public func uploadSucceed() {
        liveIconSucceed(succeedView)
        progressContainer.isHidden = true
    }
    
    public func uploadFailed() {
        liveIconFailed(failedView)
        progressView.isHidden = true
        failedLabel.isHidden = false
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        layer.borderWidth = 0.5
        
        photoImageView.isUserInteractionEnabled = true
        addSubview(photoImageView)
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加进度容器视图
        addSubview(progressContainer)
        progressContainer.snp.makeConstraints { make in
            make.edges.equalTo(photoImageView)
        }
        
        // 添加圆形进度视图
        progressContainer.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(52)
        }
        
        addSubview(succeedView)
        succeedView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(45)
        }
        
        addSubview(failedView)
        failedView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(30)
        }
        
        addSubview(failedLabel)
        failedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(failedView.snp.bottom).offset(2)
        }
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        // 添加关闭按钮
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.equalTo(6)
            make.trailing.equalTo(-6)
        }
    }
    
    @objc private func photoTapped() {
        onPhotoTap?()
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTap?()
    }
}


class ProgressView: UIView {
    
    var color: UIColor = .systemBackground {
        didSet { setupLayers() }
    }
    var progressColor: UIColor = .systemBackground {
        didSet { setupLayers() }
    }
    
    private var progress: CGFloat = 0
    
    private var layerCircle = CAShapeLayer()
    private var layerProgress = CAShapeLayer()
    private var labelPercentage: UILabel = UILabel()
    
    convenience init(_ color: UIColor) {
        self.init(frame: .zero)
        self.color = color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayers()
    }
    
    private func setupLayers() {
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = frame.size.width
        let height = frame.size.height
        let center = CGPoint(x: width / 2, y: height / 2)
        
        let radiusCircle = width / 2
        let radiusProgress = width / 2 - 2
        
        let pathCircle = UIBezierPath(arcCenter: center, radius: radiusCircle, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)
        let pathProgress = UIBezierPath(arcCenter: center, radius: radiusProgress, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)
        
        layerCircle.path = pathCircle.cgPath
        layerCircle.fillColor = UIColor.clear.cgColor
        layerCircle.lineWidth = 2
        layerCircle.strokeColor = color.cgColor
        
        layerProgress.path = pathProgress.cgPath
        layerProgress.fillColor = UIColor.clear.cgColor
        layerProgress.lineWidth = 4
        layerProgress.strokeColor = progressColor.cgColor
        layerProgress.strokeEnd = 0
        
        layer.addSublayer(layerCircle)
        layer.addSublayer(layerProgress)
        
        labelPercentage.frame = bounds
        labelPercentage.textColor = progressColor
        labelPercentage.textAlignment = .center
        addSubview(labelPercentage)
    }
    
    func setProgress(_ value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.2
        animation.fromValue = progress
        animation.toValue = value
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        layerProgress.add(animation, forKey: "animation")
        
        progress = value
        labelPercentage.text = "\(Int(value*100))%"
    }
}

extension ChatInputFloatPhotoView {
    
    func liveIconSucceed(_ view: UIView) {
        let length = view.frame.width
        let delay = (alpha == 0) ? 0.25 : 0.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: length * 0.15, y: length * 0.50))
        path.addLine(to: CGPoint(x: length * 0.5, y: length * 0.80))
        path.addLine(to: CGPoint(x: length * 1.0, y: length * 0.25))
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime() + delay
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 9
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeEnd = 0
        
        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
        
        // 1s后移除图层
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.25 + 1.0) {
            layer.removeFromSuperlayer()
        }
    }
}

extension ChatInputFloatPhotoView {
    
    func liveIconFailed(_ view: UIView) {
        let length = view.frame.width
        let delay = (alpha == 0) ? 0.25 : 0.0

        let path1 = UIBezierPath()
        let path2 = UIBezierPath()

        path1.move(to: CGPoint(x: length * 0.15, y: length * 0.15))
        path2.move(to: CGPoint(x: length * 0.15, y: length * 0.85))

        path1.addLine(to: CGPoint(x: length * 0.85, y: length * 0.85))
        path2.addLine(to: CGPoint(x: length * 0.85, y: length * 0.15))

        let paths = [path1, path2]

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.15
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        for i in 0..<2 {
            let layer = CAShapeLayer()
            layer.path = paths[i].cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = UIColor.white.cgColor
            layer.lineWidth = 9
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.strokeEnd = 0

            animation.beginTime = CACurrentMediaTime() + 0.25 * Double(i) + delay

            layer.add(animation, forKey: "animation")
            view.layer.addSublayer(layer)
        }
    }
    
    // 手动移除失败的图层
    func removeLiveIconFailed(_ view: UIView) {
        failedLabel.isHidden = true
        view.layer.sublayers?.forEach { sublayer in
            if let shapeLayer = sublayer as? CAShapeLayer {
                shapeLayer.removeFromSuperlayer()
            }
        }
    }
}
