//
//  CalculatorBrain.swift
//  Calculator-L1
//
//  Created by tue41582 on 2/10/17.
//  Copyright © 2017 tue41582. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // checks the operation done by the brain
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    // checks which was the last operation done by the brain
    private enum LastOperation {
        case Digit
        case Constant
        case UnaryOperation
        case BinaryOperation
        case Equals
        case Clear
    }
    
    // store the first value and the binary function
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstValue: Double
    }
    
    private var accumulator = 0.0 // the stored value for inputs and is used for calculations
    private var pending: PendingBinaryOperationInfo? // initialize the enum PendingBinaryOperationInfo
    private var history: [String] = [] // the history of previous calculations
    private var lastOperation: LastOperation = .Clear // initialize the enum LastOperation
    private var operations: Dictionary<String,Operation> = [ // database for all key inputs for operations
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({-$0}),
        "√" : Operation.UnaryOperation(sqrt),
        "%" : Operation.UnaryOperation({$0 / 100}),
        "ln" : Operation.UnaryOperation(log),
        "log" : Operation.UnaryOperation(log10),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "sin^-1" : Operation.UnaryOperation(asin),
        "cos^-1" : Operation.UnaryOperation(acos),
        "tan^-1" : Operation.UnaryOperation(atan),
        "x^-1" : Operation.UnaryOperation({pow($0, -1)}),
        "x^2" : Operation.UnaryOperation({pow($0, 2)}),
        "x^3" : Operation.UnaryOperation({pow($0, 3)}),
        "e^x" : Operation.UnaryOperation({pow(M_E, $0)}),
        "10^x" : Operation.UnaryOperation({pow(10, $0)}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "−" : Operation.BinaryOperation({$0 - $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "∧" : Operation.BinaryOperation({pow($0, $1)}),
        "=" : Operation.Equals
    ]
    
    // returns the accumulator to the ViewController for display
    var result: Double {
        get {
            return accumulator
        }
    }
    
    // returns the history to the ViewController for sequence
    var description: String {
        get {
            if pending != nil { // checks if it is still pending for a second value
                return history.joined(separator: "") + "..." // add "..." to end of description
            }
            return history.joined(separator: "") // or add "=" to end of description
        }
    }
    
    // get the operand from the ViewController and put it into the accumulator
    func setOperand(operand: Double) {
        if lastOperation == .UnaryOperation { // checks if it is an unary operation
            history.removeAll() //clears history to avoid duplicate values
        }
        accumulator = operand // accumulator value is now the operand value
        history.append(String(operand)) // add operand to history
        lastOperation = .Digit // set the last operation done to be a digit
    }
    
    // checks and perform the operation which should be done based on the input sent by the ViewController and the string from operations
    func performOperation(symbol: String) {
        if let operation = operations[symbol] { // checks if the string exists in operations
            switch operation {
            case .Constant(let value): // get the constant value
                history.append(symbol) // add the string to history
                accumulator = value // set the constant value to the accumulator
                lastOperation = .Constant // set the last operation done to be a constant
            case .UnaryOperation(let function): // perform a unary operation
                wrapInParens(symbol: symbol) // wrap the string in parenthesis
                accumulator = function(accumulator) // perform the unary operation and set the resulting value to the accumulator
                lastOperation = .UnaryOperation // set the last operation done to be a unary operation
            case .BinaryOperation(let function): // perform a binary operation
                if lastOperation == .Equals { // checks if last operation done was an "="
                    history.removeLast() //remove last string in history to avoid duplicate values
                }
                history.append(symbol) // add the string to history
                executePendingBinaryOperation() // execute the binary operation if there is a pending binary operation info
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstValue: accumulator) // create a new pending binary operation info
                lastOperation = .BinaryOperation // set the last operation done to be a binary operation
            case .Equals: // checks if the input is "="
                if lastOperation == .BinaryOperation { // checks if last operation done was a binary operation
                    history.append(String(accumulator)) // add the value in accumulator to history
                }
                history.append(symbol) // add "=" to history
                executePendingBinaryOperation() // execute the binary operation if there is a pending binary operation info
                lastOperation = .Equals // checks if last operation done was an "="
            }
        }
    }
    
    // checks if there is a pending binary operation to execute and if so, execute an operation using that info with a second value
    private func executePendingBinaryOperation() {
        if pending != nil { // checks if it is still an operation pending for a second value
            accumulator = pending!.binaryFunction(pending!.firstValue, accumulator) // perform the binary function using the firstValue and the function from pending binary operation info with the accumulator (secondValue) and insert the resulting value to the accumulator
            pending = nil // set pending to be empty
        }
    }
    
    private func wrapInParens(symbol: String) { // wrap the input in parenthesis
        if lastOperation == .Equals { // checks if the last operation done was an "=" ex. √(7+9)
            history.insert(")", at: history.count - 1) // insert ")" to the end of the history
            history.insert(symbol, at: 0) // insert the string to the beginning of the history
            history.insert("(", at: 1) // insert "(" after the string in the history
        } else { // ex. √(123)
            history.insert(symbol, at: history.count - 1) // insert string to the end of the history
            history.insert("(", at: history.count - 1) // insert "(" after the string in the history
            history.insert(")", at: history.count) // insert ")" after the the string in the history
        }
    }
    
    func clearBrain() { // reset the brain to its initial startup
        accumulator = 0.0
        pending = nil
        lastOperation = .Clear
        history.removeAll()
    }
}
