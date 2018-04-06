// Code for applying CSS styles to the DOM.
//
// This is not very interesting at the moment. It will get much more
// complicated if I add support for compound selectors.

// Map from CSS property names to values.
typealias PropertyMap = [String: Value]

// A node with associated style data.
struct StyledNode {
    var node: Node
    var specifiedValues: PropertyMap
    var children: [StyledNode]
}

enum Display {
    case inline
    case block
    case none
}

extension StyledNode {
    // Return the specified value of a property if it exists, otherwise `nil`.
    func value(_ name: String) -> Value? {
        return self.specifiedValues[name]
    }

    // Return the specified value of property `name`, or property `fallbackName` if that doesn't
    // exist, or value `default` if neither does.
    func lookup(_ name: String, _ fallbackName: String, _ default: Value) -> Value {
        // TODO
        return Value.keyword("")
    }

    // The value of the `display` property (defaults to inline).
    func display() -> Display {
        if case .keyword(let s)? = self.value("display") {
            switch s {
            case "block":
                return Display.block
            case "none":
                return Display.none
            default:
                return Display.inline
            }
        } else {
            return Display.inline
        }
    }
}

// Apply a stylesheet to an entire DOM tree, returning a StyledNode tree.
//
// This finds only the specified values at the moment. Eventually it should be extended to find the
// computed values too, including inherited values.
func styleTree(_ root: Node, _ stylesheet: Stylesheet) -> StyledNode {
    // TODO
    return StyledNode(node: root, specifiedValues: [:], children: [])
}

// Apply styles to a single element, returning the specified styles.
//
// To do: Allow multiple UA/author/user stylesheets, and implement the cascade.
func specifiedValues(_ elem: ElementData, _ stylesheet: Stylesheet) -> PropertyMap {
    // TODO
    return [:]
}

// A single CSS rule and the specificity of its most specific matching selector.
typealias MatchedRule = (Specificity, Rule)

// Find all CSS rules that match the given element.
func matchingRules(_ elem: ElementData, _ stylesheet: Stylesheet) -> [MatchedRule] {
    // For now, we just do a linear scan of all the rules. For large
    // documents, it would be more efficient to store the rules in hash tables
    // based on tag name, id, class, etc.
    return stylesheet.rules.compactMap({ rule in matchRule(elem, rule) })
}

// If `rule` matches `elem`, return a `MatchedRule`. Otherwise return `nil`.
func matchRule(_ elem: ElementData, _ rule: Rule) -> MatchedRule? {
    // TODO
    return nil
}

// Selector matching:
func matches(_ elem: ElementData, _ selector: Selector) -> Bool {
    switch selector {
    case .simple(let simpleSelector):
        return matchesSimpleSelector(elem, simpleSelector)
    }
}

func matchesSimpleSelector(_ elem: ElementData, _ selector: SimpleSelector) -> Bool {
    // Check type selector
    if let name = selector.tagName, elem.tagName != name {
        return false
    }
    // Check ID selector
    if let id = selector.id, elem.id() != id {
        return false
    }
    // Check class selectors
    let elemClasses = elem.classes()
    if selector.class.contains(where: { `class` in !elemClasses.contains(`class`[...]) }) {
        return false
    }
    // We didn't find any non-matching selector components.
    return true
}
