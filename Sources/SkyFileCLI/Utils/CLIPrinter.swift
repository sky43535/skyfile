//
//  CLIPrinter.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


struct CLIPrinter {
    static func success(_ msg: String) { print("✔ \(msg)") }
    static func error(_ msg: String) { print("✖ \(msg)") }
    static func info(_ msg: String) { print("ℹ \(msg)") }
}