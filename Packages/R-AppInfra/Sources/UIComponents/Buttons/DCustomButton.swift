//
//  DTextButton.swift
//  AppComponents
//
//  Created by giki on 2024/11/25.
//

import UIKit

/// A customizable UIButton that supports setting both image and text, with adjustable margins, auto-sizing based on text content,
/// configurable background and border colors for different states, and the ability to handle buttons with or without images.
/// Additionally, it supports setting different titles and images for different control states.
public class DCustomButton: UIButton {
    
    // MARK: - Properties
    
    /// Left margin for the button content
    public var leftMargin: CGFloat = 0 {
        didSet {
            updateContentEdgeInsets()
        }
    }
    
    /// Right margin for the button content
    public var rightMargin: CGFloat = 0 {
        didSet {
            updateContentEdgeInsets()
        }
    }
    
    /// Spacing between the image and the title
    public var imageTitleSpacing: CGFloat = 8 {
        didSet {
            updateEdgeInsets()
        }
    }
    
    /// Dictionary to store background colors for different states
    private var stateBackgroundColors: [UIControl.State: UIColor] = [:]
    
    /// Dictionary to store border colors for different states
    private var stateBorderColors: [UIControl.State: UIColor] = [:]
    
    /// Dictionary to store titles for different states
    private var stateTitles: [UIControl.State: String] = [:]
    
    /// Dictionary to store images for different states
    private var stateImages: [UIControl.State: UIImage?] = [:]
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    public override var isHighlighted: Bool {
          get { return false }
          set { /* 不执行任何操作，保持不高亮 */ }
      }
    
    // MARK: - Setup Methods
    
    /// Configures the initial appearance and settings of the button
    private func setupButton() {
        // Ensure the button uses Auto Layout
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Default title color and font
        self.setTitleColor(.systemBlue, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Align content to the center
        self.contentHorizontalAlignment = .center
        
        // Adjust image and title positioning
        updateEdgeInsets()
        updateContentEdgeInsets()
        
        // Set content hugging and compression resistance priorities
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Listen for state changes to update appearance
        self.addTarget(self, action: #selector(stateDidChange), for: [.allEvents])
        
        // Initial update
        updateBackgroundColor()
        updateBorderColor()
        updateTitleAndImage()
    }
    
    // MARK: - Layout Updates
    
    /// Updates the contentEdgeInsets based on left and right margins
    private func updateContentEdgeInsets() {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: rightMargin)
    }
    
    /// Updates the titleEdgeInsets and imageEdgeInsets based on the spacing and presence of an image
    private func updateEdgeInsets() {
        if let _ = currentImage {
            // If image is set, apply spacing
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpacing, bottom: 0, right: -imageTitleSpacing)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpacing, bottom: 0, right: imageTitleSpacing)
        } else {
            // If no image, remove spacing
            self.titleEdgeInsets = .zero
            self.imageEdgeInsets = .zero
        }
    }
    
    // MARK: - State Handling
    
    /// Called whenever the button's state changes to update background, border, title, and image
    @objc private func stateDidChange() {
        updateBackgroundColor()
        updateBorderColor()
        updateTitleAndImage()
    }
    
    /// Updates the background color based on the current state
    private func updateBackgroundColor() {
        if let bgColor = stateBackgroundColors[self.state] {
            self.backgroundColor = bgColor
        } else if let bgColor = stateBackgroundColors[.normal] {
            self.backgroundColor = bgColor
        } else {
            self.backgroundColor = .clear
        }
    }
    
    /// Updates the border color based on the current state
    private func updateBorderColor() {
        if let borderColor = stateBorderColors[self.state] {
            self.layer.borderColor = borderColor.cgColor
        } else if let borderColor = stateBorderColors[.normal] {
            self.layer.borderColor = borderColor.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    /// Updates the title and image based on the current state
    private func updateTitleAndImage() {
        // Update Title
        if let title = stateTitles[self.state] {
            super.setTitle(title, for: .normal)
        } else if let title = stateTitles[.normal] {
            super.setTitle(title, for: .normal)
        } else {
            super.setTitle(nil, for: .normal)
        }
        
        // Update Image
        if let image = stateImages[self.state] {
            super.setImage(image, for: .normal)
        } else if let image = stateImages[.normal] {
            super.setImage(image, for: .normal)
        } else {
            super.setImage(nil, for: .normal)
        }
        
        // Adjust edgeInsets based on image presence
        updateEdgeInsets()
    }
    
    // MARK: - Configuration Methods
    
    /// Configures the button with a title and an optional image.
    /// - Parameters:
    ///   - title: The text to display on the button.
    ///   - image: The image to display alongside the text. Pass `nil` if no image is needed.
    ///   - imageTitleSpacing: The spacing between the image and the title. Default is 8.
    public func configure(title: String, image: UIImage?, imageTitleSpacing: CGFloat = 8) {
        // Set for normal state by default
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        
        // Store in dictionaries
        stateTitles[.normal] = title
        stateImages[.normal] = image
        
        self.imageTitleSpacing = imageTitleSpacing
        updateEdgeInsets()
    }
    
    /// Sets the background color for a specific button state.
    /// - Parameters:
    ///   - color: The background color to set.
    ///   - state: The state for which to set the background color.
    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        stateBackgroundColors[state] = color
        if self.state == state {
            updateBackgroundColor()
        }
    }
    
    /// Sets the border color for a specific button state.
    /// - Parameters:
    ///   - color: The border color to set.
    ///   - state: The state for which to set the border color.
    public func setBorderColor(_ color: UIColor, for state: UIControl.State) {
        stateBorderColors[state] = color
        if self.state == state {
            updateBorderColor()
        }
    }
    
    /// Sets the title for a specific button state.
    /// - Parameters:
    ///   - title: The title to set.
    ///   - state: The state for which to set the title.
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        stateTitles[state] = title
        if self.state == state {
            super.setTitle(title, for: state)
            updateEdgeInsets()
        }
    }
    
    /// Sets the image for a specific button state.
    /// - Parameters:
    ///   - image: The image to set.
    ///   - state: The state for which to set the image.
    public override func setImage(_ image: UIImage?, for state: UIControl.State) {
        stateImages[state] = image
        if self.state == state {
            super.setImage(image, for: state)
            updateEdgeInsets()
        }
    }
    
    // MARK: - Override Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the border width is respected
        self.layer.borderWidth = self.layer.borderWidth
        updateBackgroundColor()
        updateBorderColor()
        updateTitleAndImage()
    }
}
