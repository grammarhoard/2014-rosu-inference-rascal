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
 * APTA A = <Q, Z, d, s, F+, F->
 */
private data APTA = apta();
private APTA APTA;
anno tuple[
    set[str] Q, // set of node ids
    set[str] Z, // set of input symbols
    str(str nodeId, str edgeLabel) d, // transition function
    str s, // root node's id
    set[str] Fp, // final nodes of strings in S+
    set[str] Fm // final nodes of strings in S-
] APTA@A;

/**
 * Map of Red Nodes
 */
anno map[str id, str label] APTA@redNodes;

/**
 * Red Nodes Label List
 * Used by Exbar algorithm (pickBlueNode)
 */
anno list[str] APTA@redNodesLabelList;

/**
 * Map of Blue Nodes
 */
anno map[str id, str label] APTA@blueNodes;

/**
 * Map of Edges between nodes Source -> Destination (for both, red and blue)
 * Used to get the children of a node
 */
anno map[str sourceId, set[tuple[str edgeLabel, str destId]
                           nodeEdge] nodeEdges] APTA@nodeEdges;

/**
 * Map of Edges between nodes Destination -> Source (for both, red and blue)
 * Used to get the parrents of a node
 */
anno map[str destId, set[tuple[str edgeLabel, str sourceId]
                         nodeEdge] nodeEdges] APTA@nodeEdges2;

/**
 * Alphabet (set of input symbols)
 */
private set[str] alphabet = {};

/**
 * Root Id
 */
private str rootId = "root";

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
private void addNewNode(bool isRed, str newNodeId, str nodeLabel,
    str parentNodeId, str edgeLabel
){
    if (isRed) {
        APTA@redNodes += (newNodeId: nodeLabel);
        APTA@redNodesLabelList += nodeLabel;
    } else {
        APTA@blueNodes += (newNodeId: nodeLabel);
    }

    if (parentNodeId != "") {
        // If there is a parent node id, there should also be a node edge
        if (parentNodeId notin APTA@nodeEdges) {
            APTA@nodeEdges += (parentNodeId: {<edgeLabel, newNodeId>});
        } else {
            APTA@nodeEdges[parentNodeId] += {<edgeLabel, newNodeId>};
        }
    }

    //TODO we don't need it, but rascal gives error otherwise
    set[tuple[str nodeLabel, str sourceId] nodeEdge] nodeEdgesL2 = {};

    if (edgeLabel != "") {
        nodeEdgesL2 = {<edgeLabel, parentNodeId>};
    } else {
        nodeEdgesL2 = {};
    }

    if (newNodeId notin APTA@nodeEdges2) {
        APTA@nodeEdges2 += (newNodeId: nodeEdgesL2);
    } else {
        APTA@nodeEdges2[newNodeId] += nodeEdgesL2;
    }
}

/**
 * Add path to the tree (goes recursively until the sample is consumed)
 */
private str addPath(str nodeId, str sample, str terminalNodeLabel)
{
    // Terminal Node
    if (sample == "") {
        APTA@blueNodes[nodeId] = terminalNodeLabel;
        return nodeId;
    }

    str sampleRest = size(sample) > 1 ? sample[1..] : "";
    str nodeLabelL = size(sampleRest) == 0 ? terminalNodeLabel : "";
    str nodeIdL = ""; //TODO Don't need it but Rascal gives error otherwise

    // Check if the first character of the sample exists or not as a path
    if (nodeId notin APTA@nodeEdges || sample[0] notin [nodeEdge.label |
        tuple[str label, str destId] nodeEdge <- APTA@nodeEdges[nodeId]]
    ) {
        // Create path
        nodeIdL = getUniqueNodeId();
        addNewNode(false, nodeIdL, nodeLabelL, nodeId, sample[0]);

        // Build the alphabet for APTA 0
        alphabet += {sample[0]};
    } else {
        // Update path
        // Get First Node Id By Label
        nodeIdL = [nodeEdge.destId | tuple[str edgeLabel, str destId] nodeEdge
            <- APTA@nodeEdges[nodeId], nodeEdge.edgeLabel == sample[0]][0];
    }

    return addPath(nodeIdL, sampleRest, terminalNodeLabel);
}

/**
 * APTA Transition Function
 * Returns the node id following the specified edge from a specified source node
 */
private str transitionFunction(str nodeId, str edgeLabel)
{
    return [nodeEdge.destId | tuple[str edgeLabel, str destId] nodeEdge
            <- APTA@nodeEdges[nodeId], nodeEdge.edgeLabel == edgeLabel][0];
}

/**
 * Build APTA from Training Set starting with the Root Node
 */
public APTA build(TrainingS trainingSet)
{
    // APTA init
    APTA = apta();
    APTA@redNodes = ();
    APTA@redNodesLabelList = [];
    APTA@blueNodes = ();
    APTA@nodeEdges = ();
    APTA@nodeEdges2 = ();

    // Start with the root of APTA colored red
    addNewNode(true, rootId, "", "", "");

    for (tuple[str valueL, bool typeL] sample <- trainingSet@T) {
        addPath(rootId, sample.valueL, sample.typeL ? "Accepted" : "Rejected");
    }

    // Build APTA A
    /*
    set[str] Q, // set of node ids
    set[str] Z, // set of input symbols
    str(str nodeId, str edgeLabel) d, // transition function
    str s, // root node's id
    set[str] Fp, // final nodes of strings in S+
    set[str] Fm // final nodes of strings in S-
    */
    APTA@A = <
        {id | id <- APTA@redNodes + APTA@blueNodes},
        alphabet,
        transitionFunction,
        rootId,
        {id | id <- APTA@redNodes, APTA@redNodes[id] == "Accepted"} +
            {id | id <- APTA@blueNodes, APTA@blueNodes[id] == "Accepted"},
        {id | id <- APTA@redNodes, APTA@redNodes[id] == "Rejected"} +
            {id | id <- APTA@blueNodes, APTA@blueNodes[id] == "Rejected"}
    >;
    return APTA;
}
