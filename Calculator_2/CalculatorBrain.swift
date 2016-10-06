//
//  CalculatorBrain.swift
//  Calculator_2
//
//  Created by Phuc Nguyen on 10/2/16.
//  Copyright © 2016 Phuc Nguyen. All rights reserved.
//

import Foundation


class CalculatorBrain {
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var currentPrecedence = Int.max
    private var isPartialResult: Bool {
        return pending != nil
    }
    
    func setOperand (_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        accumulatorDescription = String(format: "%g", operand)
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
        case Clear
        
    }

    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var functionDescription: (String, String) -> String
        var operandDescription: String
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant (M_E),
        "C": Operation.Clear,
        "±": Operation.UnaryOperation({-$0}, {"-(" + $0 + ")"}),
        "√": Operation.UnaryOperation (sqrt, {"√" + $0 + ")"}),
        "cos": Operation.UnaryOperation (cos, {"cos(" + $0 + ")"}),
        "sin": Operation.UnaryOperation (sin, {"sin(" + $0 + ")"}),
        "tan": Operation.UnaryOperation (tan, {"tan(" + $0 + ")"}),
        "×": Operation.BinaryOperation({$0 * $1}, {$0 + " x " + $1}, 1),
        "÷": Operation.BinaryOperation({$0 / $1}, {$0 + " / " + $1}, 1),
        "−": Operation.BinaryOperation({$0 - $1}, {$0 + " - " + $1}, 0),
        "+": Operation.BinaryOperation({$0 + $1}, {$0 + " + " + $1}, 0),
        "=": Operation.Equals,
        "log": Operation.UnaryOperation(log10, {"log10(" + $0 + ")"}),
        "ln": Operation.UnaryOperation(log2, {"log2(" + $0 + ")"}),
        "%": Operation.UnaryOperation({$0/100}, {"%(" + $0 + ")"})
        
    ]
    
    var description: String {
        get {
            if !isPartialResult {
                return accumulatorDescription + " ="
            } else {
                return pending!.functionDescription(pending!.operandDescription, pending!.operandDescription != accumulatorDescription ? accumulatorDescription : "..." )
            }
        }
    }
    
    private var accumulatorDescription = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }

    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
        
    }

    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant (let value):
                accumulator = value
                accumulatorDescription = symbol
            case .UnaryOperation (let function, let funcDescription):
                accumulator = function(accumulator)
                accumulatorDescription = funcDescription(accumulatorDescription)
            case .BinaryOperation (let function, let funcDescription, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    accumulatorDescription = "(" + accumulatorDescription + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function,
                                                     firstOperand: accumulator,
                                                     functionDescription: funcDescription,
                                                     operandDescription: accumulatorDescription)
                
            case .Equals:
                executePendingBinaryOperation()
            case .Clear:
                clear()
                
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            accumulatorDescription = pending!.functionDescription(pending!.operandDescription, accumulatorDescription)
            pending = nil
        }
    }
    
    
    typealias PropertyList = AnyObject
    
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
}
