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

  @IBOutlet private var textFields: [TextFieldEffects]!
  @IBOutlet private var hoshiTextField: HoshiTextField?

  /**
   Set this value to true if you want to see all the "firstName"
   textFields prepopulated with the name "Raul" (for testing purposes)
   */
  let prefillTextFields = false
  var cells = [Any](repeating: 0, count: 2)

  override func viewDidLoad() {
    super.viewDidLoad()
//    guard prefillTextFields == true else { return }

//    _ = textFields.map { $0.text = "Raul" }

    hoshiTextField?.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyAwesomeCell")
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default,
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

    let textField = HoshiTextField(frame: cell.frame)
    if indexPath.row == 0 {
      textField.placeholderLabel.text = "Firstname"
      textField.placeholder = "Firstname"
    } else {
      textField.placeholderLabel.text = "Lastname"
      textField.placeholder = "Lastname"
    }
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
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    if let text = textField.text, !text.isEmpty, let textField = textField as? HoshiTextField {
      textField.showError(message: "Bad Name!")
    }
  }
}
