// A simple parser for a tiny subset of HTML.
//
// Can parse basic opening and closing tags, and text nodes.
//
// Not yet supported:
//
// * Comments
// * Doctypes and processing instructions
// * Self-closing tags
// * Non-well-formed markup
// * Character entities

import Foundation

// Parse an HTML document and return the root element.
func parse(_ source: String) -> Node {
    var parser = HTMLParser(pos: 0, input: source)
    let nodes = parser.parseNodes()
    // If the document contains a root element, just return it. Otherwise, create one.
    if nodes.count == 1 {
        return nodes[0]
    } else {
        return elem("html", [:], nodes)
    }
}

struct HTMLParser {
    var pos: UInt
    var input: String
}

extension HTMLParser {
    // Parse a sequence of sibling nodes.
    mutating func parseNodes() -> [Node] {
        var nodes: [Node] = []
        while true {
            self.consumeWhitespace()
            if self.eof() || self.startsWith("</") {
                break
            }
            nodes.append(self.parseNode())
        }
        return nodes
    }

    // Parse a single node.
    mutating func parseNode() -> Node {
        switch self.nextChar() {
        case "<":
            return self.parseElement()
        default:
            return self.parseText()
        }
    }

    // Parse a single element, including its open tag, contents, and closing tag.
    mutating func parseElement() -> Node {
        // Opening tag.
        let _assert1 = self.consumeChar() == "<"
        assert(_assert1)
        let tagName = self.parseTagName()
        let attrs = self.parseAttributes()
        let _assert2 = self.consumeChar() == ">"
        assert(_assert2)
        // Contents.
        let children = self.parseNodes()
        // Closing tag.
        let _assert3 = self.consumeChar() == "<"
        assert(_assert3)
        let _assert4 = self.consumeChar() == "/"
        assert(_assert4)
        let _assert5 = self.parseTagName() == tagName
        assert(_assert5)
        let _assert6 = self.consumeChar() == ">"
        assert(_assert6)
        return elem(tagName, attrs, children)
    }

    // Parse a tag or attribute name.
    mutating func parseTagName() -> String {
        return self.consumeWhile() { c in
            switch c {
            case "a"..."z", "A"..."Z", "0"..."9":
                return true
            default:
                return false
            }
        }
    }

    // Parse a list of name="value" pairs, separated by whitespace.
    mutating func parseAttributes() -> AttrMap {
        var attributes: AttrMap = [:]
        while true {
            self.consumeWhitespace()
            if self.nextChar() == ">" {
                break
            }
            let (name, value) = self.parseAttr()
            attributes[name] = value
        }
        return attributes
    }

    // Parse a single name="value" pair.
    mutating func parseAttr() -> (String, String) {
        let name = self.parseTagName()
        let _assert1 = self.consumeChar() == "="
        assert(_assert1)
        let value = self.parseAttrValue()
        return (name, value)
    }

    // Parse a quoted value.
    mutating func parseAttrValue() -> String {
        let open_quote = self.consumeChar()
        let _assert1 = open_quote == "\"" || open_quote == "'"
        assert(_assert1)
        let value = self.consumeWhile({ c in c != open_quote })
        let _assert2 = self.consumeChar() == open_quote
        assert(_assert2)
        return value
    }

    // Parse a text node.
    mutating func parseText() -> Node {
        return text(self.consumeWhile({ c in c != "<" }))
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
    mutating func consumeChar() -> UnicodeScalar {
        // TODO
        return " "
    }

    // Read the current character without consuming it.
    func nextChar() -> UnicodeScalar {
        // TODO
        return " "
    }

    // Does the current input start with the given string?
    func startsWith(_ s: String) -> Bool {
        // TODO
        return false
    }

    // Return true if all input is consumed.
    func eof() -> Bool {
        // TODO
        return false
    }
}
