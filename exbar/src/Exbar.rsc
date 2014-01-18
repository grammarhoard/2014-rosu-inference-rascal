/**
 * Exbar Module
 */
module Exbar

import TrainingSet;
import APTA;
import GraphVis;

// import IO;

// Maximum number of red nodes
private int maxRed;

/**
 * STARTing point
 */
public void main()
{
    // Add positive and negative samples
    /* Sample Set 1
    TrainingSet::addSample("1",   true);
    TrainingSet::addSample("110", true);
    TrainingSet::addSample("01",  true);
    TrainingSet::addSample("001", true);

    TrainingSet::addSample("00",  false);
    TrainingSet::addSample("10",  false);
    TrainingSet::addSample("000", false);
    */
    /* Sample Set 2
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

    /* Other Samples
    // TrainingSet::addSampleFromFile(|file:///home/orosu/Documents/workspaces/eclipse/Exbar/src/Exbar.rsc|, true);
    // TrainingSet::addSampleFromDirectory(|file:///home/orosu/Documents/workspaces/eclipse/Exbar/src|, true);
    */

    maxRed = 1;
    APTA::build();
    GraphVis::build();

    // Search 
}
