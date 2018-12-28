
//
//  File.swift
//  TextFieldsDemo
//
//  Created by Gonzalo Erro on 12/28/18.
//  Copyright © 2018 Raul Riera. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  convenience init (hex:String) {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
      cString = cString.substring(from: cString.index(after: cString.startIndex))
    }

    if ((cString.count) != 6) {
      self.init(red:0.5, green:0.5, blue:0.5, alpha:1.0)
      return
    }

    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}
