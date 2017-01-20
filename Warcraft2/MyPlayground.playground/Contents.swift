//: Playground - noun: a place where people can play

import UIKit

let x = 10, y = 10

switch (x, y) {
case (x, y) where x == 10: print("Yes!")
case (x, y) where y == 10: print("Also!")
default: print("Default!")
}
