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
  private var placeholderColorEmptyState: UIColor = UIColor(red: 109/255, green: 113/255, blue: 122/255, alpha: 1)
  private var placeholderColorInputState: UIColor = UIColor(red: 109/255, green: 113/255, blue: 122/255, alpha: 1)

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
      updateBorder()
      updatePlaceholder()
    }
  }

  private let borderThicknessActive: CGFloat = 1.0
  private let borderThicknessInactive: CGFloat = 1.0
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
        return CGPoint(x: 0, y: 17)
      } else {
        return CGPoint(x: 0, y: 22)
      }
    }
  }

  private var placeholderLabelOriginalText: String?
  private var placeholderFont: UIFont? = UIFont(name: "Roboto-Regular", size: 15)
  private var errorFont: UIFont? = UIFont(name: "Roboto-Regular", size: 13)
  private var height: CGFloat = 55

  private var errorLabel = UILabel()
  private var textEntryMode = false

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    configureUI()
  }

  override open func awakeFromNib() {
    super.awakeFromNib()
    configureUI()
  }

  private func configureUI() {
    initPlaceholderFont()
    configurePlaceholderLabelFrame()
    configurePlaceholderFont()
    configureErrorLabel()
    updateBorder()
    updatePlaceholder()
    addSublayers()
    addLabels()
    frame = CGRect(x: frame.origin.x,
                   y: frame.origin.y,
                   width: frame.size.width,
                   height: height)
  }

  private func addSublayers() {
    layer.addSublayer(inactiveBorderLayer)
    layer.addSublayer(activeBorderLayer)
  }

  private func addLabels() {
    addSubview(placeholderLabel)
    addSubview(errorLabel)
  }

  open override func setNeedsLayout() {
    super.setNeedsLayout()
    updatePlaceholder()
    updateBorder()
    frame = CGRect(x: frame.origin.x,
                   y: frame.origin.y,
                   width: frame.size.width,
                   height: height)
  }

  open func showError(message: String) {
    errorLabel.text = message
    errorLabel.textColor = borderActiveColor
    errorLabel.sizeToFit()
    errorLabel.isHidden = false
    placeholderLabel.isHidden = textEntryMode ? true : false

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

  }

  open func setViewsForTextEntry() {
    viewForTextEntryAnimationClosure()
  }

  override open func animateViewsForTextEntry() {
    guard let text = text else { return }
    textEntryMode = true
    hideError()

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
    textEntryMode = false

    UIView.animate(withDuration: 0.35,
                   delay: 0.0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 2.0,
                   options: UIView.AnimationOptions.beginFromCurrentState,
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

    if errorLabel.isHidden {
      inactiveBorderLayer.isHidden = false
      activeBorderLayer.isHidden = true
    } else {
      inactiveBorderLayer.isHidden = true
      activeBorderLayer.isHidden = false
    }
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
