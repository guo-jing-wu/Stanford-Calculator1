//
//  ViewController.swift
//  Calculator-L1
//
//  Created by tue41582 on 2/10/17.
//  Copyright © 2017 tue41582. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var calculatorBrain = CalculatorBrain() // initialize the CalculatorBrain
    @IBOutlet private weak var display: UILabel! // display the result
    @IBOutlet private weak var sequence: UILabel! // display the history
    private var userIsInMiddleOfTyping = false // checks if the user is in middle of typing
    private var decimalUsed = false // checks if there is already a decimal
    private var displayValue: Double { // allow to get value as a double and set it as a string
        get { // return as a double
            return Double(display.text!)!
        } set { // change double into a string and put it into the display
            display.text = String(newValue)
        }
    }
    
    // the digit and . buttons
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle! // get the string from the button pressed
        if digit == "." && decimalUsed == false { // checks if "." is pressed and decimalUsed is false
            decimalUsed = true // set decimalUsed to true
        } else if digit == "." && decimalUsed == true { // checks if "." is pressed and decimalUsed is true
            return // do not allow "." to be added to the display
        }
        if userIsInMiddleOfTyping { // checks if the user is in the middle of typing
            let currentDisplay = display.text! // store the current display
            display.text = currentDisplay + digit // add the digit to the display
        } else {
            display.text = digit // insert the first digit
        }
        userIsInMiddleOfTyping = true
    }
    
    // all the mathematical symbol buttons
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInMiddleOfTyping { // checks if the user is in the middle of typing
            calculatorBrain.setOperand(operand: displayValue) // store operand to the brain
            userIsInMiddleOfTyping = false
            decimalUsed = false
        }
        if let mathematicalSymbol = sender.currentTitle { // checks if sender.currentTitle has an actual value to perform an operation
            calculatorBrain.performOperation(symbol: mathematicalSymbol) //perform an operation using the string from the button pressed
        }
        displayValue = calculatorBrain.result // display the result given by the brain
        sequence.text = calculatorBrain.description // display how the result was performed
    }
    
    // the C button
    @IBAction private func clear(_ sender: UIButton) {
        calculatorBrain.clearBrain() // reset the brain to its initial startup
        display.text = "0" // reset display
        sequence.text = "0" // reset sequence
        userIsInMiddleOfTyping = false // reset if the user is in the middle of typing
        decimalUsed = false // reset decimal used
    }
}

