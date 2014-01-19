/**
 * Augmented Prefix Tree Acceptor (APTA) Module
 * APTA(S+, S-) A = <Q, Z, d, s, F+, F-> where
 *     S+ = set of positive samples
 *     S- = set of negative samples
 *     Q = finite non-empty set of nodes
 *     Sigma Z = finite non-empty set of input symbols (alphabet)
 *     delta d : Q x Z -> Q = transition function
 *     s (element of) Q = start (root node)
 *     F+ (subset of) Q = final nodes of strings in S+
 *     F- (subset of) Q = final nodes of strings in S-
 * size(A) = |Q| (total number of elements in Q / total number of nodes)
 * APTA is built from the beginning in the red-blue framework
 */
module APTA

import TrainingSet;

// import IO;
import String;

/**
 * Map of Red Nodes
 */
public map[str id, str label] redNodes = ();

/**
 * Red Nodes Label List
 * Used by Exbar algorithm (pickBlueNode)
 */
public list[str] redNodesLabelList = [];

/**
 * Map of Blue Nodes
 */
public map[str id, str label] blueNodes = ();

/**
 * Map of Edges between nodes Source -> Destination (for both, red and blue)
 * Used to get the children of a node
 */
public map[str sourceId, set[tuple[str nodeLabel, str destId]
                                  nodeEdge] nodeEdges] nodeEdges = ();

/**
 * Map of Edges between nodes Destination -> Source (for both, red and blue)
 * Used to get the parrents of a node
 */
public map[str destId, set[tuple[str nodeLabel, str sourceId]
                                nodeEdge] nodeEdges] nodeEdges2 = ();

/**
 * Root Id
 */
public str rootId = "root";

/**
 * Node Id Auto Increment
 */
private int nodeIdAutoIncrement = 0;

/**
 * Get an unique node id
 */
private str getUniqueNodeId()
{
    nodeIdAutoIncrement+=1;
    return "Node-<nodeIdAutoIncrement>";
}

/**
 * Add New Node
 */
public void addNewNode(bool isRed, str newNodeId, str nodeLabel,
    str parentNodeId, str edgeLabel
){
    if (isRed) {
        redNodes += (newNodeId: nodeLabel);
        redNodesLabelList += nodeLabel;
    } else {
        blueNodes += (newNodeId: nodeLabel);
    }
    
    if (parentNodeId != "") {
        if (parentNodeId notin nodeEdges) {
            nodeEdges += (parentNodeId: {<edgeLabel, newNodeId>});
        } else {
            nodeEdges[parentNodeId] += {<edgeLabel, newNodeId>};
        }
        if (newNodeId notin nodeEdges2) {
            nodeEdges2 += (newNodeId: {<edgeLabel, parentNodeId>});
        } else {
            nodeEdges2[newNodeId] += {<edgeLabel, parentNodeId>};
        }
    }
}

/**
 * Add path to the tree (goes recursively until the sample is consumed)
 */
private str addPath(str nodeId, str sample, str terminalNodeLabel)
{
    // Terminal Node
    if (sample == "") {
        blueNodes[nodeId] = terminalNodeLabel;
        return nodeId;
    }

    str sampleRest = size(sample) > 1 ? sample[1..] : "";
    str nodeLabelL = size(sampleRest) == 0 ? terminalNodeLabel : "";
    str nodeIdL = ""; //TODO Don't need it but Rascal gives error otherwise

    // Check if the first character of the sample exists or not as a path
    if (nodeId notin nodeEdges || sample[0] notin [nodeEdge.label |
        tuple[str label, str destId] nodeEdge <- nodeEdges[nodeId]]
    ) {
        // Create path
        nodeIdL = getUniqueNodeId();
        addNewNode(false, nodeIdL, nodeLabelL, nodeId, sample[0]);
    } else {
        // Update path
        // Get First Node Id By Label
        nodeIdL = [nodeEdge.destId | tuple[str label, str destId] nodeEdge
            <- nodeEdges[nodeId], nodeEdge.label == sample[0]][0];
    }

    return addPath(nodeIdL, sampleRest, terminalNodeLabel);
}

/**
 * Build APTA from Training Set starting with the Root Node
 */
public void build()
{
    // Start with the root of APTA colored red
    addNewNode(true, rootId, "", "", "");

    for (tuple[str valueL, bool typeL] sample <- TrainingSet::trainingSet0) {
        addPath(rootId, sample.valueL, sample.typeL ? "Accepted" : "Rejected");
    }
}
