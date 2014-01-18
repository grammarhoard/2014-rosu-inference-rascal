/**
 * Augmented Prefix Tree Acceptor (APTA) Module
 */
module APTA

// import IO;
import String;

/**
 * Augmented Prefix Tree Acceptor Data Type
 */
data APTree = Node(str nodeLabel, map[str edgeLabel, APTree child] children);

/**
 * Default tree with just the root node
 */
private APTree tree0 = Node("root", ());

/**
 * Build APTA starting with tree0 (root node) from positive and negative samples
 */
public APTree build(set[str] positiveSamples, set[str] negativeSamples)
{
    for (str sample <- positiveSamples) {
        tree0 = addPath(tree0, sample, "Accepted");
    }
    for (str sample <- negativeSamples) {
        tree0 = addPath(tree0, sample, "Rejected");
    }
    return tree0;
}

/**
 * Add path to the tree (goes recursively until the sample is consumed)
 */
private APTree addPath(APTree treeL, str sample, str terminalNodeLabel)
{
    // Match first node of the local tree to get the first children
    if (Node(nodeLabel, children) := treeL) {

        // Terminal Node
        if (sample == "") {
            return Node(terminalNodeLabel, children);
        }

        str sampleRest = size(sample) > 1 ? sample[1..] : "";
        str nodeLabelL = size(sampleRest) == 0 ? terminalNodeLabel : "";

        if (sample[0] notin children) {
            return Node(nodeLabel, children +
                // Add new child tree
                (sample[0]: addPath( Node(nodeLabelL, ()), sampleRest, terminalNodeLabel) )
            );
        } else {
            return Node(nodeLabel, (children - (sample[0]: Node("", ())))+
                // Update child tree
                (sample[0]: addPath( children[sample[0]], sampleRest, terminalNodeLabel) )
            );
        }
    } else {
        throw "The tree did NOT match (<treeL>)!";
    }
}

