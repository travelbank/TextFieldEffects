//
//  HoshiTextField.swift
//  TextFieldEffects
//
//  Created by Raúl Riera on 24/01/2015.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

/**
 An HoshiTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the lower edge of the control.
 */
@IBDesignable open class HoshiTextField: TextFieldEffects {

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

   This property applies a color to the complete placeholder string. The default value for this property is a black color.
   */
  @IBInspectable dynamic open var placeholderColor: UIColor = .black {
    didSet {
      updatePlaceholder()
    }
  }

  /**
   The scale of the placeholder font.

   This property determines the size of the placeholder label relative to the font size of the text field.
   */
  @IBInspectable dynamic open var placeholderFontSize: CGFloat = 12  {
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
      updateBorder()
      updatePlaceholder()
    }
  }

  private let borderThickness: (active: CGFloat, inactive: CGFloat) = (active: 2, inactive: 0.5)
  private let placeholderInsets = CGPoint(x: 0, y: 25)
  private let textFieldInsets = CGPoint(x: 0, y: 6)
  private let inactiveBorderLayer = CALayer()
  private let activeBorderLayer = CALayer()
  private var activePlaceholderPoint: CGPoint = CGPoint(x:0, y:-2)
  private var inactivePlaceholderPoint: CGPoint = CGPoint(x:0, y:20)
  private var placeholderLabelOriginalText: String?
  private var placeholderFont: UIFont?

  open func showError(message: String) {
    placeholderLabelOriginalText = placeholderLabel.text
    placeholderLabel.textColor = borderActiveColor
    placeholderLabel.text = message
    activeBorderLayer.frame = self.rectForBorder(self.borderThickness.active)
    activeBorderLayer.isHidden = false
    placeholderLabel.sizeToFit()
  }

  open func hideError() {
    placeholderLabel.text = placeholderLabelOriginalText != nil ? placeholderLabelOriginalText : placeholderLabel.text
    placeholderLabel.textColor = placeholderColor
    activeBorderLayer.isHidden = true
    placeholderLabel.sizeToFit()
  }

  // MARK: - TextFieldEffects

  override open func drawViewsForRect(_ rect: CGRect) {
    let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: rect.size.width, height: rect.size.height))

    placeholderLabel.frame = frame.insetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
    placeholderLabel.frame.origin = self.inactivePlaceholderPoint
    placeholderFont = UIFont(name: "Roboto-Regular", size: 12)
    updateBorder()
    updatePlaceholder()

    layer.addSublayer(inactiveBorderLayer)
    layer.addSublayer(activeBorderLayer)
    addSubview(placeholderLabel)
  }

  override open func animateViewsForTextEntry() {
    if text!.isEmpty {
      UIView.animate(withDuration: 0.35,
                     delay: 0.0,
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 1.0,
                     options: .beginFromCurrentState,
                     animations: ({
                      self.placeholderLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                      self.placeholderLabel.font = self.placeholderFont
                      self.placeholderLabel.sizeToFit()
                      self.placeholderLabel.frame.origin = self.activePlaceholderPoint
                     }), completion: { _ in
                      self.animationCompletionHandler?(.textEntry)

      })
    }
  }

  override open func animateViewsForTextDisplay() {
    if text!.isEmpty {
      UIView.animate(withDuration: 0.35, delay: 0.0,
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 2.0,
                     options: UIViewAnimationOptions.beginFromCurrentState, animations: ({
                      self.placeholderLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                      guard let fontSize = self.font?.pointSize else { return }
                      guard let fontName = self.font?.fontName else { return }
                      self.placeholderLabel.font = UIFont(name: fontName,
                                                          size: fontSize)
                      self.placeholderLabel.sizeToFit()
                      self.placeholderLabel.frame.origin = self.inactivePlaceholderPoint
                     }), completion: { [weak self] _  in
                      guard let strongSelf = self else { return }
                      strongSelf.animationCompletionHandler?(.textDisplay)
      })
    }
  }

  // MARK: - Private

  private func updateBorder() {
    inactiveBorderLayer.frame = rectForBorder(borderThickness.inactive)
    inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor

    activeBorderLayer.frame = rectForBorder(borderThickness.active)
    activeBorderLayer.backgroundColor = borderActiveColor?.cgColor
    activeBorderLayer.isHidden = true
  }

  private func updatePlaceholder() {
    placeholderLabel.text = placeholder
    placeholderLabel.textColor = placeholderColor
    guard let fontSize = self.font?.pointSize else { return }
    guard let fontName = self.font?.fontName else { return }
    self.placeholderLabel.font = UIFont(name: fontName,
                                        size: fontSize)
    placeholderLabel.sizeToFit()

    if isFirstResponder || text!.isNotEmpty {
      animateViewsForTextEntry()
    }
  }

  private func rectForBorder(_ thickness: CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness), size: CGSize(width: frame.width, height: thickness))
  }

  // MARK: - Overrides

  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
  }

  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
  }
}
