//
//  ExampleTableViewController.swift
//  TextFieldEffects
//
//  Created by Raúl Riera on 28/08/2015.
//  Copyright © 2015 Raul Riera. All rights reserved.
//

import UIKit
import TextFieldEffects

class ExampleTableViewController : UITableViewController, UITextFieldDelegate {

  var travelbankNight: UIColor = UIColor(hex: "#1B2432")
  var travelbankSilver: UIColor = UIColor(hex: "#E0E2E6")
  var travelbankRadical: UIColor = UIColor(hex: "#FC3B60")

  @IBOutlet private var textFields: [TextFieldEffects]!
  @IBOutlet private var hoshiTextField: HoshiTextField?

  /**
   Set this value to true if you want to see all the "firstName"
   textFields prepopulated with the name "Raul" (for testing purposes)
   */
  let prefillTextFields = false
  var cells: [(String, CGFloat)] = [(String, CGFloat)]()

  override func viewDidLoad() {
    super.viewDidLoad()
    cells = [(NSLocalizedString("Firstname", comment: "Firstname example label"), 24),
             (NSLocalizedString("Lastname", comment: "Lastname example label"), 15)]
    hoshiTextField?.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyAwesomeCell")
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let delete = UITableViewRowAction(style: UITableViewRowAction.Style.default,
                                      title: "Delete" ,
                                      handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                                        self.cells.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .automatic)

    })
    delete.backgroundColor = UIColor.red
    return [delete]
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cells.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyAwesomeCell") else {
      return UITableViewCell()
    }
    let configuredCell = configure(cell: cell, with: cells[indexPath.row].0, height: cells[indexPath.row].1)
    return configuredCell
  }

  private func configure(cell: UITableViewCell, with placeholder: String, height: CGFloat) -> UITableViewCell {
    let textField = HoshiTextField(frame: cell.frame)
    textField.borderActiveColor = travelbankRadical
    textField.borderInactiveColor = travelbankNight
    textField.font = UIFont(name: "Roboto-Regular", size: height)
    textField.placeholder = placeholder
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    cell.contentView.addSubview(textField)
    let views: [String: Any] = [
      "cell": cell,
      "view": textField]
    var allConstraints: [NSLayoutConstraint] = []
    allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[view]-|",
                                                     metrics: nil,
                                                     views: views)
    allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]",
                                                     options: [.alignAllCenterY],
                                                     metrics: nil,
                                                     views: views)
    NSLayoutConstraint.activate(allConstraints)
    cell.addConstraints(allConstraints)
    return cell
  }

  // MARK: - TextFieldDelegate

  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let textField = textField as? HoshiTextField else { return }
    textField.hideError()
  }
  @available(iOS 10.0, *)
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    if let text = textField.text, !text.isEmpty, let textField = textField as? HoshiTextField {
      let message = NSLocalizedString("Error", comment: "Error Message for TextField")
      textField.showError(message: message)
    }
  }
}
