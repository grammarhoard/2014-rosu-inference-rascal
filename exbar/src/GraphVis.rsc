/**
 * Grap Visualization Module
 */
module GraphVis

import APTA;

import vis::Figure;
import vis::Render;
import IO;

/**
 * Build Graph Visualization for APTA in red-blue framework
 */
public void build()
{
    print("Red Nodes"); iprintln(APTA::redNodes);
    print("Blue Nodes"); iprintln(APTA::blueNodes);
    print("Node Edges"); iprintln(APTA::nodeEdges);

    list[Figure] nodes = [];
    list[Edge] edges = [];
    Figure edgeArrow = text("▲", size(10));

    // Get all the nodes (red and blue)
    for (str nodeId <- APTA::redNodes) {
        nodes += ellipse(
            text(APTA::redNodes[nodeId]),
            id(nodeId),
            mouseOver(box(text(nodeId), fillColor("white"))),
            size(50),
            fillColor("red")
        );
    }
    for (str nodeId <- APTA::blueNodes) {
        nodes += ellipse(
            text(APTA::blueNodes[nodeId]),
            id(nodeId),
            mouseOver(box(text(nodeId), fillColor("white"))),
            size(50),
            fillColor("blue")
        );
    }

    // Get all the edges
    for (str sourceId <- APTA::nodeEdges) {
        if (sourceId == "") {
            continue;
        }
        //TODO one edge's label is not shown (probably because the edge is curved)
        for (tuple[str label, str destId] nodeEdge <- APTA::nodeEdges[sourceId]) {
            edges += edge(
                sourceId,
                nodeEdge.destId,
                label(text(nodeEdge.label)),
                toArrow(edgeArrow)
            );
        }
    }

    render(graph(nodes, edges, hint("layered"), gap(50)));
}