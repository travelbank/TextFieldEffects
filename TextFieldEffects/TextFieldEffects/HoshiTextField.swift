//
//  HoshiTextField.swift
//  TextFieldEffects
//
//  Created by Raúl Riera on 24/01/2015.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

typealias VoidClosure = () -> Void

/**
 An HoshiTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the lower edge of the control.
 */
@IBDesignable open class HoshiTextField: TextFieldEffects {

    /**
     Fixed textfield height, change this only if designs change
     */
    @IBInspectable dynamic open var textFieldHeight: CGFloat = 45 {
        didSet {
            if let font = font, font.pointSize > CGFloat(15) {
                height = textFieldHeight + 10
            }
        }
    }

    /**
     The color of the border when it has no content.

     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderInactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    /**
     The color of the border when it has content.

     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderActiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    /**
     The color of the placeholder text.

     This property applies a color to the complete placeholder string.
     */
    private var placeholderColorEmptyState: UIColor = UIColor(red: 198/255, green: 200/255, blue: 204/255, alpha: 1)
    private var placeholderColorInputState: UIColor = UIColor(red: 164/255, green: 167/255, blue: 174/255, alpha: 1)

    /**
     The scale of the placeholder font.

     This property determines the size of the placeholder label relative to the font size of the text field.
     */
    var placeholderFontSize: CGFloat = 13  {
        didSet {
            updatePlaceholder()
        }
    }

    override open var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    override open var bounds: CGRect {
        didSet {
            frame = CGRect(x: frame.origin.x,
                           y: frame.origin.y,
                           width: bounds.size.width,
                           height: height)
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        initPlaceholderFont()
    }



    private let borderThicknessActive: CGFloat = 1.0
    private let borderThicknessInactive: CGFloat = 0.5
    private let placeholderInsets = CGPoint(x: 0, y: 25)
    private let textFieldInsets = CGPoint(x: 0, y: 4.5)
    private let inactiveBorderLayer = CALayer()
    private let activeBorderLayer = CALayer()
    private var activePlaceholderPoint: CGPoint {
        get {
            if let font = font, font.pointSize > 15 {
                return  CGPoint(x: 0, y: -2)
            } else {
                return CGPoint(x: 0, y: 3)
            }
        }
    }
    private var inactivePlaceholderPoint: CGPoint {
        get {
            if let font = font, font.pointSize > 15 {
                return CGPoint(x: 0, y: 18)
            } else {
                return CGPoint(x: 0, y: 27)
            }
        }
    }

    private var placeholderLabelOriginalText: String?
    private var placeholderFont: UIFont? = UIFont(name: "Roboto-Regular", size: 16)
    private var errorFont: UIFont? = UIFont(name: "Roboto-Regular", size: 13)
    private var height: CGFloat = 55

    private var errorLabel = UILabel()

    open func showError(message: String) {
        errorLabel.text = message
        errorLabel.textColor = borderActiveColor
        errorLabel.sizeToFit()
        errorLabel.isHidden = false
        placeholderLabel.isHidden = true

        activeBorderLayer.frame = rectForBorder(borderThicknessActive)
        activeBorderLayer.isHidden = false
    }

    open func hideError() {
        errorLabel.isHidden = true
        activeBorderLayer.isHidden = true
        placeholderLabel.isHidden = false
    }

    // MARK: - TextFieldEffects

    override open func drawViewsForRect(_ rect: CGRect) {
        frame = CGRect(x: frame.origin.x,
                       y: frame.origin.y,
                       width: rect.size.width ,
                       height: height)
        configurePlaceholderLabelFrame()
        configurePlaceholderFont()
		configureErrorLabel()
        updateBorder()
        updatePlaceholder()

        layer.addSublayer(inactiveBorderLayer)
        layer.addSublayer(activeBorderLayer)
        addSubview(placeholderLabel)
		addSubview(errorLabel)
    }

    open func setViewsForTextEntry() {
        viewForTextEntryAnimationClosure()
    }

	override open func animateViewsForTextEntry() {
		hideError()

		guard let text = text else { return }
		let duration = text.isEmpty ? 0.35 : 0.0
		UIView.animate(withDuration: duration,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 1.0,
					   options: .beginFromCurrentState,
					   animations: ({
						self.viewForTextEntryAnimationClosure()
					}), completion: { _ in
						self.animationCompletionHandler?(.textEntry)
		})
	}

    override open func animateViewsForTextDisplay() {
        guard let text = text,
			  text.isEmpty else { return }

		UIView.animate(withDuration: 0.35,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 2.0,
					   options: UIViewAnimationOptions.beginFromCurrentState,
					   animations: ({
						self.viewForTextDisplayAnimationClosure()
					   }), completion: { _  in
						self.animationCompletionHandler?(.textDisplay)
		})
    }

    // MARK: - Private

    private var viewForTextEntryAnimationClosure: VoidClosure {
        return {
            self.placeholderLabel.font = self.placeholderFont
            self.placeholderLabel.sizeToFit()
            self.placeholderLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.placeholderLabel.frame.origin = self.activePlaceholderPoint
            self.placeholderLabel.textColor = self.placeholderColorInputState
        }
    }

    private var viewForTextDisplayAnimationClosure: VoidClosure {
        return {
            guard let font = UIFont(name: "Roboto-Regular",
                                    size: (self.font?.pointSize)!) else { return }
            self.placeholderLabel.font = font
            self.placeholderLabel.sizeToFit()
            self.placeholderLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.placeholderLabel.frame.origin = self.inactivePlaceholderPoint
            self.placeholderLabel.textColor = self.placeholderColorEmptyState
        }
    }

    private func initPlaceholderFont() {
        self.placeholderLabel.textColor = placeholderColorEmptyState
        guard let font = placeholderFont else { return }
        let sizedFont = UIFont.init(name: font.fontName, size: (self.font?.pointSize)!)
        self.placeholderLabel.font = sizedFont
    }

    private func configurePlaceholderLabelFrame() {
        placeholderLabel.frame = frame.insetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
        placeholderLabel.frame.origin = inactivePlaceholderPoint
    }

    private func configurePlaceholderFont() {
        if let font = placeholderFont {
            placeholderFont = font
        }
    }

    private func configureErrorLabel() {
		errorLabel.frame.origin = activePlaceholderPoint
		errorLabel.font = errorFont
		errorLabel.isHidden = true
    }

    private func updateBorder() {
        inactiveBorderLayer.frame = rectForBorder(borderThicknessInactive)
        inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor

        activeBorderLayer.frame = rectForBorder(borderThicknessActive)
        activeBorderLayer.backgroundColor = borderActiveColor?.cgColor
        activeBorderLayer.isHidden = true
    }

    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.sizeToFit()

        guard let text = text else {
            return
        }

        if isFirstResponder || text.isNotEmpty {
            animateViewsForTextEntry()
        }
    }

    private func rectForBorder(_ thickness: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: floor(frame.height-thickness)),
                      size: CGSize(width: frame.width, height: thickness))
    }

    // MARK: - Overrides

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
    }
}
