// A simple parser for a tiny subset of CSS.
//
// To support more CSS syntax, it would probably be easiest to replace this
// hand-rolled parser with one based on a library or parser generator.

import Foundation

// Data structures:

struct Stylesheet {
    var rules: [Rule]
}

struct Rule {
    var selectors: [Selector]
    var declarations: [Declaration]
}

enum Selector {
    case simple(SimpleSelector)
}

struct SimpleSelector {
    var tagName: String?
    var id: String?
    var `class`: [String]
}

struct Declaration {
    var name: String
    var value: Value
}

enum Value {
    case keyword(String)
    case length(Float, Unit)
    case colorValue(Color)
}

enum Unit {
    case px
}

struct Color {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

typealias Specificity = (UInt, UInt, UInt)

extension Selector {
    func specificity() -> Specificity {
        // TODO
        return (0, 0, 0)
    }
}

extension Value {
    // Return the size of a length in px, or zero for non-lengths.
    func toPx() -> Float {
        switch self {
        case .length(let f, Unit.px):
            return f
        default:
            return 0.0
        }
    }
}

// Parse a whole CSS stylesheet.
func parse(_ source: String) -> Stylesheet {
    var parser = CSSParser(pos: 0, input: source)
    return Stylesheet(rules: parser.parseRules())
}

struct CSSParser {
    var pos: UInt
    var input: String
}

extension CSSParser {
    // Parse a list of rule sets, separated by optional whitespace.
    mutating func parseRules() -> [Rule] {
        var rules: [Rule] = []
        while true {
            self.consumeWhitespace()
            if self.eof() {
                break
            }
            rules.append(self.parseRule())
        }
        return rules
    }

    // Parse a rule set: `<selectors> { <declarations> }`.
    mutating func parseRule() -> Rule {
        return Rule(
            selectors: self.parseSelectors(),
            declarations: self.parseDeclarations())
    }

    // Parse a comma-separated list of selectors.
    mutating func parseSelectors() -> [Selector] {
        var selectors: [Selector] = []
        while true {
            selectors.append(Selector.simple(self.parseSimpleSelector()))
            self.consumeWhitespace()
            switch self.nextChar() {
            case ",":
                self.consumeChar()
                self.consumeWhitespace()
            case "{":
                break
            case let c:
                fatalError("Unexpected character \(c) in selector list")
            }
        }
        // Return selectors with highest specificity first, for use in matching.
        selectors.sort(by: { a, b in b.specificity() < a.specificity() })
        return selectors
    }

    // Parse one simple selector, e.g.: `type#id.class1.class2.class3`
    mutating func parseSimpleSelector() -> SimpleSelector {
        var selector = SimpleSelector(tagName: nil, id: nil, class: [])
        while !self.eof() {
            switch self.nextChar() {
            case "#":
                self.consumeChar()
                selector.id = self.parseIdentifier()
            case ".":
                self.consumeChar()
                selector.class.append(self.parseIdentifier())
            case "*":
                // universal selector
                self.consumeChar()
            case let c where validIdentifierChar(c):
                selector.tagName = self.parseIdentifier()
            default:
                break
            }
        }
        return selector
    }

    // Parse a list of declarations enclosed in `{ ... }`.
    mutating func parseDeclarations() -> [Declaration] {
        let _assert1 = self.consumeChar() == "{"
        assert(_assert1)
        var declarations: [Declaration] = []
        while true {
            self.consumeWhitespace()
            if self.nextChar() == "}" {
                self.consumeChar()
                break
            }
            declarations.append(self.parseDeclaration())
        }
        return declarations
    }

    // Parse one `<property>: <value>;` declaration.
    mutating func parseDeclaration() -> Declaration {
        let propertyName = self.parseIdentifier()
        self.consumeWhitespace()
        let _assert1 = self.consumeChar() == ":"
        assert(_assert1)
        self.consumeWhitespace()
        let value = self.parseValue()
        self.consumeWhitespace()
        let _assert2 = self.consumeChar() == ";"
        assert(_assert2)
        return Declaration(name: propertyName, value: value)
    }

    // Methods for parsing values:

    mutating func parseValue() -> Value {
        switch self.nextChar() {
        case "0"..."9":
            return self.parseLength()
        case "#":
            return self.parseColor()
        default:
            return Value.keyword(self.parseIdentifier())
        }
    }

    mutating func parseLength() -> Value {
        return Value.length(self.parseFloat(), self.parseUnit())
    }

    mutating func parseFloat() -> Float {
        let s = self.consumeWhile() { c in
            switch c {
            case "0"..."9", ".":
                return true
            default:
                return false
            }
        }
        return Float(s)!
    }

    mutating func parseUnit() -> Unit {
        switch self.parseIdentifier().lowercased() {
        case "px":
            return Unit.px
        default:
            fatalError("unrecognized unit")
        }
    }

    mutating func parseColor() -> Value {
        let _assert1 = self.consumeChar() == "#"
        assert(_assert1)
        return Value.colorValue(Color(
            r: self.parseHexPair(),
            g: self.parseHexPair(),
            b: self.parseHexPair(),
            a: 255))
    }

    // Parse two hexademical digits.
    mutating func parseHexPair() -> UInt8 {
        // TODO
        return 0
    }

    // Parse a property name or keyword.
    mutating func parseIdentifier() -> String {
        return self.consumeWhile(validIdentifierChar)
    }

    // Consume and discard zero or more whitespace characters.
    mutating func consumeWhitespace() {
        _ = self.consumeWhile(CharacterSet.whitespaces.contains)
    }

    // Consume characters until `test` returns false.
    mutating func consumeWhile(_ test: (UnicodeScalar) -> Bool) -> String {
        var result = String()
        while !self.eof() && test(self.nextChar()) {
            result.unicodeScalars.append(self.consumeChar())
        }
        return result
    }

    // Return the current character, and advance self.pos to the next character.
    @discardableResult
    mutating func consumeChar() -> UnicodeScalar {
        // TODO
        return " "
    }

    // Read the current character without consuming it.
    func nextChar() -> UnicodeScalar {
        // TODO
        return " "
    }

    // Return true if all input is consumed.
    func eof() -> Bool {
        // TODO
        return false
    }
}

func validIdentifierChar(_ c: UnicodeScalar) -> Bool {
    switch c {
    case "a"..."z", "A"..."Z", "0"..."9", "-", "_":
        // TODO: Include U+00A0 and higher.
        return true
    default:
        return false
    }
}
