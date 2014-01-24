/**
 * Evidence Driven State Merging (EDSM) Module
 * Algorithm for DFA learning from given training data
 */
module EDSM

import TrainingSet;
import APTA;
import DFA;
import GraphVis;

import IO;

/**
 * APTA
 */
private APTA APTA;

/**
 * -(minus) Infinity
 */
private int mInf = -2147483648;

/**
 * STARTing point
 */
public void main()
{
    // Add positive and negative samples
    /*
    // Sample Set 1
    TrainingSet::addSample("1",   true);
    TrainingSet::addSample("110", true);
    TrainingSet::addSample("01",  true);
    TrainingSet::addSample("001", true);

    TrainingSet::addSample("00",  false);
    TrainingSet::addSample("10",  false);
    TrainingSet::addSample("000", false);

    // Sample Set 2
    TrainingSet::addSample("1",    true);
    TrainingSet::addSample("11",   true);
    TrainingSet::addSample("1111", true);

    TrainingSet::addSample("0",    false);
    TrainingSet::addSample("101",  false);
    */

    // Sample Set 3
    TrainingSet::addSample("a",    true);
    TrainingSet::addSample("abaa", true);
    TrainingSet::addSample("bb",   true);

    TrainingSet::addSample("abb",  false);
    TrainingSet::addSample("b",    false);

    // Build APTA
    APTA = APTA::build(TrainingSet::build(), true);
    print("APTA 0: "); iprintln(APTA);
    // GraphVis::build(APTA);

    // EDSM Search
    edsmSearch();
    GraphVis::build(APTA);

    // Build DFA
    DFA DFA = DFA::build(APTA);
    print("DFA 0: "); iprintln(DFA);
}

/**
 * EDSM Search
 */
private void edsmSearch()
{
    set[tuple[str redNodeId, str blueNodeId, int mergingScore] merge] merges = {};
    int mergingScore = 0;
    int maxMergingScore = mInf;
    int localMaxMergingScore = mInf;

    // 1. Evaluate all red/blue merges
    for (str blueNodeId <- APTA@blueNodes) {
        for (str redNodeId <- APTA@redNodes) {
            mergingScore = buildScore(redNodeId, blueNodeId);
            merges += {<redNodeId, blueNodeId, mergingScore>};
        }

        int localMaxMergingScore = mInf;
        for (tuple[str redNodeId, str blueNodeId, int mergingScore] merge <- merges) {
            if (localMaxMergingScore < merge.mergingScore) {
                localMaxMergingScore = merge.mergingScore;
            }
            if (maxMergingScore < merge.mergingScore) {
                maxMergingScore = merge.mergingScore;
            }
        }

        // 2. If there exists a blue node that cannot be merged
        //     with any red node, promote it to red and go to step 1
        if (localMaxMergingScore == mInf) {
            println("B: <blueNodeId> cannot be merged with any red node, " +
                    "so it is promoted to red!");
            colorNodeRed(blueNodeId);
            edsmSearch();
            return;
        }
    }

    // 3. If no blue node is promoteable, perform the highest scoring
    //     red/blue merge and then go to step 1
    for (tuple[str redNodeId, str blueNodeId, int mergingScore] merge <- merges) {
        if (merge.mergingScore == maxMergingScore) {
            println("Merging R: <merge.redNodeId> with B: <merge.blueNodeId>!");
            tryMerge(merge.redNodeId, merge.blueNodeId);
            edsmSearch();
            return;
        }
    }

    // 4. Halt
}

/**
 * Build merging score as the number of strings that end in the same state
 *    if that merge is done.
 * - conflicting labels: -infinity
 * - no labels: 0
 * - otherwise: number of labels - 1
 */
private int buildScore(str redNodeId, str blueNodeId)
{
    if (APTA@redNodes[redNodeId] != APTA@blueNodes[blueNodeId]) {
        return mInf; // conflicting labels
    }

    set[tuple[str edgeLabel, str nodeLabel] nodeEdge] redNodesChildren = {};
    set[tuple[str edgeLabel, str nodeLabel] nodeEdge] blueNodesChildren = {};
    int numberOfLabels = 0;

    if (redNodeId in APTA@nodeEdges) {
        redNodesChildren = {<nodeEdge.edgeLabel, getLabelByNodeId(nodeEdge.destId)> |
            tuple[str edgeLabel, str destId] nodeEdge <- APTA@nodeEdges[redNodeId]};
    }
    if (blueNodeId in APTA@nodeEdges) {
        blueNodesChildren = {<nodeEdge.edgeLabel, getLabelByNodeId(nodeEdge.destId)> |
            tuple[str edgeLabel, str destId] nodeEdge <- APTA@nodeEdges[blueNodeId]};
    }

    // Check determinization rule (the children of equivalent nodes must be equivalent)
    for (tuple[str edgeLabel, str nodeLabel] nodeEdgeRed <- redNodesChildren) {
        for (tuple[str edgeLabel, str nodeLabel] nodeEdgeBlue <- blueNodesChildren) {
            if (nodeEdgeRed.edgeLabel == nodeEdgeBlue.edgeLabel && 
                nodeEdgeRed.nodeLabel != nodeEdgeBlue.nodeLabel
            ) {
                return mInf; // conflicting labels
            } else {
                numberOfLabels += 1;
            }
        }
    }

    return numberOfLabels == 0 ? 0: numberOfLabels - 1;
}

/**
 * Color a blue node to red
 */
private void colorNodeRed(str nodeId)
{
    APTA@redNodes += (nodeId: APTA@blueNodes[nodeId]);
    APTA@blueNodes = APTA@blueNodes - (nodeId: "");

    // Color its primary children to blue
    if (nodeId notin APTA@nodeEdges) {
        return;
    }
    for (tuple[str edgeLabel, str destId] nodeEdge <- APTA@nodeEdges[nodeId]) {
        APTA@blueNodes += (nodeEdge.destId: APTA@whiteNodes[nodeEdge.destId]);
        APTA@whiteNodes = APTA@whiteNodes - (nodeEdge.destId: "");
    }
}

/**
 * Try to merge a red node with a blue node
 */
private void tryMerge(str redNodeId, str blueNodeId)
{
    // Get the nodes pointing to the blue node and make them point the red node
    for (tuple[str labelL, str sourceId] edgeL <- APTA@nodeEdges2[blueNodeId]) {

        APTA@nodeEdges[edgeL.sourceId] -= {<edgeL.labelL, blueNodeId>};
        APTA@nodeEdges[edgeL.sourceId] += {<edgeL.labelL, redNodeId>};

        APTA@nodeEdges2[redNodeId] += {<edgeL.labelL, edgeL.sourceId>};
        APTA@nodeEdges2[blueNodeId] -= {<edgeL.labelL, edgeL.sourceId>};
    }

    // Get the blue nodes' children and make them children of the red node
    if (blueNodeId in APTA@nodeEdges) {
        for (tuple[str label, str destId] edgeL <- APTA@nodeEdges[blueNodeId]) {
            // Color them to blue
            APTA@blueNodes += (edgeL.destId: APTA@whiteNodes[edgeL.destId]);
            APTA@whiteNodes = APTA@whiteNodes - (edgeL.destId: "");

            if (redNodeId notin APTA@nodeEdges) {
                APTA@nodeEdges += (redNodeId: {edgeL});
            } else {
                APTA@nodeEdges[redNodeId] += {edgeL};
            }
            APTA@nodeEdges[blueNodeId] -= {edgeL};

            APTA@nodeEdges2[edgeL.destId] += {<edgeL.label, redNodeId>};
            APTA@nodeEdges2[edgeL.destId] -= {<edgeL.label, blueNodeId>};
        }
    }

    // Remove blue node
    APTA@blueNodes -= (blueNodeId: "");
}

/**
 * Get Label node by node id
 */
private str getLabelByNodeId(str nodeId)
{
    if (nodeId in APTA@redNodes) {
        return APTA@redNodes[nodeId];
    }
    if (nodeId in APTA@blueNodes) {
        return APTA@blueNodes[nodeId]; 
    }
    return APTA@whiteNodes[nodeId];
}
