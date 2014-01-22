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

    // Build APTA
    APTA = APTA::build(TrainingSet::build());
    print("APTA 0: "); iprintln(APTA);
    // GraphVis::build(APTA);

    //TODO

    GraphVis::build(APTA);

    // Build DFA
    DFA DFA = DFA::build(APTA);
    print("DFA 0: "); iprintln(DFA);
}