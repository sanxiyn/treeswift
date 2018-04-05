// Basic DOM data structures.

typealias AttrMap = [String: String]

struct Node {
    // data common to all nodes:
    var children: [Node]
    // data specific to each node type:
    var nodeType: NodeType
}

enum NodeType {
    case element(ElementData)
    case text(String)
}

struct ElementData {
    var tagName: String
    var attributes: AttrMap
}

// Constructor functions for convenience:

func text(_ data: String) -> Node {
    return Node(children: [], nodeType: NodeType.text(data))
}

func elem(_ name: String, _ attrs: AttrMap, _ children: [Node]) -> Node {
    return Node(
        children: children,
        nodeType: NodeType.element(ElementData(
            tagName: name,
            attributes: attrs)))
}

// Element methods

extension ElementData {
    func id() -> String? {
        return self.attributes["id"]
    }

    func classes() -> Set<Substring> {
        if let classlist = self.attributes["class"] {
            return Set(classlist.split(separator: " "))
        } else {
            return []
        }
    }
}
