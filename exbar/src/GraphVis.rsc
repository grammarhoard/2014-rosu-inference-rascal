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
    print("Node Edges2"); iprintln(APTA::nodeEdges2);

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
        for (tuple[str label, str destId] nodeEdge <- APTA::nodeEdges[sourceId]) {
            edges += edge(
                sourceId,
                nodeEdge.destId,
                //TODO some edge labels are not shown
                //TODO because of the labels, some whole graphs are not shown
                // label(text(nodeEdge.label)),
                toArrow(edgeArrow)
            );
            println("sourceId: <sourceId>; destId: <nodeEdge.destId>; " +
                    "label: <nodeEdge.label>");
        }
    }

    render(graph(nodes, edges, hint("layered"), gap(50)));
}
