/**
 * Exbar Module
 * Algorithm for the exact inference of minimal DFA
 */
module Exbar

import TrainingSet;
import APTA;
import DFA;
import GraphVis;

import IO;
import Map;
import List;

/**
 * APTA
 */
private APTA APTA;

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
    // Sample Set 1
    TrainingSet::addSample("1",   true);
    TrainingSet::addSample("110", true);
    TrainingSet::addSample("01",  true);
    TrainingSet::addSample("001", true);

    TrainingSet::addSample("00",  false);
    TrainingSet::addSample("10",  false);
    TrainingSet::addSample("000", false);
    /*
    // Sample Set 2
    TrainingSet::addSample("1",    true);
    TrainingSet::addSample("11",   true);
    TrainingSet::addSample("1111", true);

    TrainingSet::addSample("0",    false);
    TrainingSet::addSample("101",  false);
    */
    /*
    // Sample Set 3
    TrainingSet::addSample("a",    true);
    TrainingSet::addSample("abaa", true);
    TrainingSet::addSample("bb",   true);

    TrainingSet::addSample("abb",  false);
    TrainingSet::addSample("b",    false);
    */
    // TrainingSet::addSampleFromFile(|file:///home/orosu/Documents/Repos/gi/exbar/src/TrainingSet.rsc|, false);

    // Build APTA
    APTA = APTA::build(TrainingSet::build());
    print("APTA 0: "); iprintln(APTA);
    // GraphVis::build(APTA);

    // EXBAR Search
    exbarSearch();
    GraphVis::build(APTA);

    // Build DFA
    DFA DFA = DFA::build(APTA);
    print("DFA 0: "); iprintln(DFA);
}

/**
 * Exbar Search
 */
private void exbarSearch()
{
    maxRed += 1;

    // Limits the number of searches to the number of red nodes
    if (size(APTA@redNodes) > maxRed) {
        println("Limit exceeded (number of redNodes is greater than maxRed)!");
        return;
    }

    // No blue nodes exist
    if (size(APTA@blueNodes) == 0) {
        // Found a solution
        println("Solution Found (No blue nodes exist)!");
        return;
    }

    tuple[str id, str label] blueNodeL = pickBlueNode();
    println("Picked: blueNodeL: <blueNodeL>");

    // Try to merge with all red nodes that have the same label
    for (str redNodeId <- [redNode | redNode <- APTA@redNodes,
         APTA@redNodes[redNode] == blueNodeL.label]
    ) {
         if (tryMerge(redNodeId, blueNodeL.id) == true) {
             // Succeed in merging the blue node with a red node
             println("R: <redNodeId> merged successfully with B: <blueNodeL>!");
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
        for (str blueNodeId <- APTA@blueNodes) {

            // The blue node's label does not exist in the red node's label set
            if (APTA@blueNodes[blueNodeId] notin APTA@redNodesLabelList) {
                // Force promotion to red
                colorNodeRed(blueNodeId);
                continue;
            }
            //TODO maybe more criterias for finding this kind of nodes
        }
        noPossibleMerges = 1;
    }

    // 2. Look for blue nodes that have only one or more possible merge(s)
    for (str blueNodeId <- APTA@blueNodes) {
        // Get possible number of merges (number of red nodes with same label)
        int possibleNoMergesL = size([nodeLabel | nodeLabel <-
            APTA@redNodesLabelList, nodeLabel == APTA@blueNodes[blueNodeId]]);

        if (possibleNoMergesL <= noPossibleMerges) {
            if (possibleNoMergesL == 0) {
                // Force promotion to red
                colorNodeRed(blueNodeId);
                continue;
            } else {
                return <blueNodeId, APTA@blueNodes[blueNodeId]>;
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
    APTA@redNodes += (nodeId: APTA@blueNodes[nodeId]);
    APTA@redNodesLabelList += APTA@blueNodes[nodeId];

    APTA@blueNodes = APTA@blueNodes - (nodeId: "");
    maxRed += 1;
}

/**
 * Try to merge a red node with a blue node
 */
private bool tryMerge(str redNodeId, str blueNodeId)
{
    println("Trying to merge R: <redNodeId> with B: <blueNodeId>...");

    //TODO WTF StackOverflow() otherwise
    map[str sourceId, set[tuple[str edgeLabel, str destId]
                               nodeEdge] nodeEdges] nE = APTA@nodeEdges;
    map[str destId, set[tuple[str edgeLabel, str sourceId]
                             nodeEdge] nodeEdges] nE2 = APTA@nodeEdges2;

    // Check if the nodes can be merged
    // If the nodes are connected, merge is not allowed
    /*
    //TODO It is not needed, but I am not sure
    if ((redNodeId in nE && blueNodeId in [nodeEdge.destId |
            // Check if the red node has a child relation with the blue node
            tuple[str nodeLabel, str destId] nodeEdge <- nE[redNodeId]]) ||
        (redNodeId in nE2 && blueNodeId in [nodeEdge.sourceId |
            // Check if the red node has a parrent relation with the blue node
            tuple[str nodeLabel, str sourceId] nodeEdge <- nE2[redNodeId]])
    ) {
        println("Merge failed! the nodes are connected");
        return false;
    }
    */

    // If the nodes have transitions on a common symbol
    //     that lead to nodes which are not equivalent, merge is not allowed
    //TODO ATTENTION - you may want to rewrite this more elegantly
    if (redNodeId in nE && blueNodeId in nE) {
        // Both nodes have children
        set[tuple[str edgeLabel, str nodeLabel] nodeEdge] redNodesChildren =
            {<nodeEdge.edgeLabel, nodeEdge.destId in APTA@redNodes ?
                APTA@redNodes[nodeEdge.destId]: APTA@blueNodes[nodeEdge.destId]> |
                tuple[str edgeLabel, str destId] nodeEdge <- nE[redNodeId]};
        ;
        set[tuple[str edgeLabel, str nodeLabel] nodeEdge] blueNodesChildren =
            {<nodeEdge.edgeLabel, nodeEdge.destId in APTA@redNodes ?
                APTA@redNodes[nodeEdge.destId]: APTA@blueNodes[nodeEdge.destId]> |
                tuple[str edgeLabel, str destId] nodeEdge <- nE[blueNodeId]};
        ;
        for (tuple[str edgeLabel, str nodeLabel] nodeEdgeRed <- redNodesChildren) {
            for (tuple[str edgeLabel, str nodeLabel] nodeEdgeBlue <- blueNodesChildren) {
                if (nodeEdgeRed.edgeLabel == nodeEdgeBlue.edgeLabel && 
                    nodeEdgeRed.nodeLabel != nodeEdgeBlue.nodeLabel
                ) {
                    println("Merge failed! the nodes have children on a " +
                        "common symbol that lead to nodes which are not equivalent");
                    return false; 
                }
            }
        }
    }
    /*
    //TODO It is not needed, but I am not sure
    if (redNodeId in nE && blueNodeId in nE2) {
        // Both nodes have parents
        set[tuple[str edgeLabel, str nodeLabel] nodeEdge] redNodesParents =
            {<nodeEdge.edgeLabel, nodeEdge.sourceId in APTA@redNodes ?
                APTA@redNodes[nodeEdge.sourceId]: APTA@blueNodes[nodeEdge.sourceId]> |
                tuple[str edgeLabel, str sourceId] nodeEdge <- nE2[redNodeId]};
        ;
        set[tuple[str edgeLabel, str nodeLabel] nodeEdge] blueNodesParents =
            {<nodeEdge.edgeLabel, nodeEdge.sourceId in APTA@redNodes ?
                APTA@redNodes[nodeEdge.sourceId]: APTA@blueNodes[nodeEdge.sourceId]> |
                tuple[str edgeLabel, str sourceId] nodeEdge <- nE2[blueNodeId]};
        ;
        for (tuple[str edgeLabel, str nodeLabel] nodeEdgeRed <- redNodesParents) {
            for (tuple[str edgeLabel, str nodeLabel] nodeEdgeBlue <- blueNodesParents) {
                if (nodeEdgeRed.edgeLabel == nodeEdgeBlue.edgeLabel && 
                    nodeEdgeRed.nodeLabel != nodeEdgeBlue.nodeLabel
                ) {
                    println("Merge failed! the nodes have parents on a " +
                        "common symbol that lead to nodes which are not equivalent");
                    return false; 
                }
            }
        }
    }
    */

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

            nE2[edgeL.destId] += {<edgeL.label, redNodeId>};
            nE2[edgeL.destId] -= {<edgeL.label, blueNodeId>};
        }
    }

    // Remove blue node
    APTA@blueNodes -= (blueNodeId: "");

    //TODO WTF StackOverflow() otherwise
    APTA@nodeEdges = nE;
    APTA@nodeEdges2 = nE2;

    return true;
}
