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
  var placeholderFontSize: CGFloat = 12  {
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

  private let borderThickness: (active: CGFloat, inactive: CGFloat) = (active: 2, inactive: 0.5)
  private let placeholderInsets = CGPoint(x: 0, y: 25)
  private let textFieldInsets = CGPoint(x: 0, y: 6)
  private let inactiveBorderLayer = CALayer()
  private let activeBorderLayer = CALayer()
  private var activePlaceholderPoint: CGPoint = CGPoint(x: 0, y: -2)
  private var inactivePlaceholderPoint: CGPoint {
    get {
      if let font = font, font.pointSize > 15 {
        return CGPoint(x: 0, y: 8)
      } else {
        return CGPoint(x: 0, y: 17)
      }
    }
  }

  private var placeholderLabelOriginalText: String?
  private var placeholderFont: UIFont?
  private var height: CGFloat = 45

  open func showError(message: String) {
    placeholderLabelOriginalText = placeholderLabel.text
    placeholderLabel.textColor = borderActiveColor
    placeholderLabel.text = message
    activeBorderLayer.frame = rectForBorder(borderThickness.active)
    activeBorderLayer.isHidden = false
    placeholderLabel.sizeToFit()
  }

  open func hideError() {
    placeholderLabel.text = placeholderLabelOriginalText ?? placeholderLabel.text
    placeholderLabel.textColor = placeholderColor
    activeBorderLayer.isHidden = true
    placeholderLabel.sizeToFit()
  }

  // MARK: - TextFieldEffects

  override open func drawViewsForRect(_ rect: CGRect) {
    frame = CGRect(x: frame.origin.x,
                   y: frame.origin.y,
                   width: rect.size.width ,
                   height: height)
    configurePlaceholderLabelFrame()
    configurePlaceholderFont()
    updateBorder()
    updatePlaceholder()

    layer.addSublayer(inactiveBorderLayer)
    layer.addSublayer(activeBorderLayer)
    addSubview(placeholderLabel)
  }

  override open func animateViewsForTextEntry() {
    guard let text = text else {
      return
    }

    if text.isEmpty {
      UIView.animate(withDuration: 0.35,
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
  }

  override open func animateViewsForTextDisplay() {
    guard let text = text else {
      return
    }

    if text.isEmpty {
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
  }

  // MARK: - Private

  private var viewForTextEntryAnimationClosure: VoidClosure {
    return {
      self.placeholderLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
      self.placeholderLabel.font = self.placeholderFont
      self.placeholderLabel.sizeToFit()
      self.placeholderLabel.frame.origin = self.activePlaceholderPoint
    }
  }

  private var viewForTextDisplayAnimationClosure: VoidClosure {
    return { self.placeholderLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      guard let font = self.font else { return }
      self.placeholderLabel.font = font
      self.placeholderLabel.sizeToFit()
      self.placeholderLabel.frame.origin = self.inactivePlaceholderPoint
    }
  }

  private func initPlaceholderFont() {
    guard let font = font else { return }
    self.placeholderLabel.font = font

  }

  private func configurePlaceholderLabelFrame() {
    placeholderLabel.frame = frame.insetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
    placeholderLabel.frame.origin = inactivePlaceholderPoint
  }

  private func configurePlaceholderFont() {
    if let font = UIFont(name: "Roboto-Regular", size: 12) {
      placeholderFont = font
    }
  }

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
    placeholderLabel.sizeToFit()

    guard let text = text else {
      return
    }

    if isFirstResponder || text.isNotEmpty {
      animateViewsForTextEntry()
    }
  }

  private func rectForBorder(_ thickness: CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness),
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
