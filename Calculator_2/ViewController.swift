//
//  ViewController.swift
//  Calculator_2
//
//  Created by Phuc Nguyen on 10/1/16.
//  Copyright © 2016 Phuc Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if !(textCurrentlyInDisplay.range(of: ".") != nil && digit == ".") {
                display.text = textCurrentlyInDisplay + digit
            }
            historyLabel.text = brain.description
        } else {
            display.text = digit
            if digit == "." {
                display.text = "0."
            }
        }
        userIsInTheMiddleOfTyping = true
        
    }
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func restore(_ sender: UIButton) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        savedProgram = brain.program
    }
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        
        set {
            display.text = String(newValue)
            historyLabel.text = brain.description + (brain.isPartialResult ? "..." : " =")
        }
    }
    @IBAction func backSpace(_ sender: UIButton) {
        if (userIsInTheMiddleOfTyping && (display.text?.isEmpty)!) || display.text == "0" {
            display.text = "0"
            return
        }
        
        var currentText = display.text!
        currentText.remove(at: currentText.startIndex)
        if (currentText.isEmpty) {
            currentText = "0"
        }
        display.text = currentText
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
}

