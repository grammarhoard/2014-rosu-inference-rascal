/**
 * Exbar Module
 */
module Exbar

import TrainingSet;
import APTA;
import GraphVis;

import IO;
import Map;
import List;

/**
 * Current number of possible merges
 */
private int noPossibleMerges = 0;

/**
 * Limits the number of searches to the number of red nodes
 */
private int maxRed = 0;

/**
 * STARTing point
 */
public void main()
{
    // Add positive and negative samples
    // Sample Set 3
    TrainingSet::addSample("a",    true);
    TrainingSet::addSample("abaa", true);
    TrainingSet::addSample("bb",   true);

    TrainingSet::addSample("abb",  false);
    TrainingSet::addSample("b",    false);

    APTA::build();
    GraphVis::build();
    exbarSearch();
    GraphVis::build();
}

/**
 * Exbar Search
 */
private void exbarSearch()
{
    maxRed += 1;

    // Limits the number of searches to the number of red nodes
    if (size(APTA::redNodes) > maxRed) {
        println("Limit exceeded!");
        return;
    }

    // No blue nodes exist
    if (size(APTA::blueNodes) == 0) {
        // Found a solution
        println("Solution Found!");
        return;
    }

    tuple[str id, str label] blueNodeL = pickBlueNode();
    println("blueNodeL: <blueNodeL>");

    // Try to merge with all red nodes that have the same label
    for (str redNodeId <- [redNode | redNode <- APTA::redNodes,
         APTA::redNodes[redNode] == blueNodeL.label]
    ) {
         if (tryMerge(redNodeId, blueNodeL.id) == true) {
             // Succeed in merging the blue node with a red node
             println("Merging succeeded!");
             exbarSearch();
             return;
         }
    }

    // The blue node could not be merged with neither of the red nodes
    // Force promotion to red
    colorNodeRed(blueNodeL.id);

    // Continue the search
    exbarSearch();
}

/**
 * Picks a blue node that can be disposed of in the fewest ways:
 *     the preffered kind of blue node can't be merged with any red node,
 *         which means force promotion to red
 *     the next best kind of blue node has only one possible merge,
 *         resulting in two choices to be searched
 *     etc.
 */
private tuple[str nodeId, str nodeLabel] pickBlueNode()
{
    if (noPossibleMerges == 0) {
        // 1. Look for blue nodes that can't be merged with any red node
        for (str blueNodeId <- APTA::blueNodes) {

            // The blue node's label does not exist in the red node's label set
            if (APTA::blueNodes[blueNodeId] notin APTA::redNodesLabelList) {
                // Force promotion to red
                colorNodeRed(blueNodeId);
                continue;
            }
            //TODO maybe more criterias for finding this kind of nodes
        }
        noPossibleMerges = 1;
    }

    // 2. Look for blue nodes that have only one or more possible merge(s)
    for (str blueNodeId <- APTA::blueNodes) {
        // Get possible number of merges (number of red nodes with the same label)
        int possibleNoMergesL = size([nodeLabel | nodeLabel <-
            APTA::redNodesLabelList, nodeLabel == APTA::blueNodes[blueNodeId]]);

        if (possibleNoMergesL <= noPossibleMerges) {
            if (possibleNoMergesL == 0) {
                // Force promotion to red
                colorNodeRed(blueNodeId);
                continue;
            } else {
                return <blueNodeId, APTA::blueNodes[blueNodeId]>;
            }
        }
    }
    noPossibleMerges += 1;
    return pickBlueNode();
}

/**
 * Color a blue node to red
 */
private void colorNodeRed(str nodeId)
{
    APTA::addNewNode(true, nodeId, APTA::blueNodes[nodeId], "", "");
    APTA::blueNodes = APTA::blueNodes - (nodeId: "");
}

/**
 * Try to merge a red node with a blue node
 */
private bool tryMerge(str redNodeId, str blueNodeId)
{
    print("----------------- Before merge\nRed Nodes"); iprintln(APTA::redNodes);
    print("Blue Nodes"); iprintln(APTA::blueNodes);
    print("Node Edges"); iprintln(APTA::nodeEdges);
    print("Node Edges2"); iprintln(APTA::nodeEdges2);
    println("---------------\nredNodeId: <redNodeId>; blueNodeId: <blueNodeId>");

    //TODO WTF StackOverflow() otherwise
    map[str sourceId, set[tuple[str nodeLabel, str destId]
                               nodeEdge] nodeEdges] nE = APTA::nodeEdges;
    map[str destId, set[tuple[str nodeLabel, str sourceId]
                             nodeEdge] nodeEdges] nE2 = APTA::nodeEdges2;

    // Get the nodes pointing to the blue node and make them point the red node
    for (tuple[str labelL, str sourceId] edgeL <- nE2[blueNodeId]) {

        nE[edgeL.sourceId] -= {<edgeL.labelL, blueNodeId>};
        nE[edgeL.sourceId] += {<edgeL.labelL, redNodeId>};

        nE2[redNodeId] += {<edgeL.labelL, edgeL.sourceId>};
        nE2[blueNodeId] -= {<edgeL.labelL, edgeL.sourceId>};
    }

    // Get the blue nodes' children and make them children of the red node
    if (blueNodeId in nE) {
        for (tuple[str label, str destId] edgeL <- nE[blueNodeId]) {
            if (redNodeId notin nE) {
                nE += (redNodeId: {edgeL});
            } else {
                nE[redNodeId] += {edgeL};
            }
            nE[blueNodeId] -= {edgeL};
        }
    }

    // Remove blue node
    APTA::blueNodes -= (blueNodeId: "");

    //TODO WTF StackOverflow() otherwise
    APTA::nodeEdges = nE;
    APTA::nodeEdges2 = nE2;

    print("----------------- After merge\nRed Nodes"); iprintln(APTA::redNodes);
    print("Blue Nodes"); iprintln(APTA::blueNodes);
    print("Node Edges"); iprintln(APTA::nodeEdges);
    print("Node Edges2"); iprintln(APTA::nodeEdges2);

    return true;
}
