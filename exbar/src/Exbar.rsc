/**
 * Exbar Module
 */
module Exbar

import APTA;

import IO;

/**
 * Set of positive example strings
 */
private set[str] positiveSamples = {};

/**
 * Set of negative example strings
 */
private set[str] negativeSamples = {};

/**
 * START point
 */
public void main()
{
    // Add positive and negative samples
    /* Sample Set 1
    addSample("1",   true);
    addSample("110", true);
    addSample("01",  true);
    addSample("001", true);

    addSample("00",  false);
    addSample("10",  false);
    addSample("000", false);
    */
    /* Sample Set 2
    addSample("1",    true);
    addSample("11",   true);
    addSample("1111", true);

    addSample("0",    false);
    addSample("101",  false);
    */
    // Sample Set 3
    addSample("a",    true);
    addSample("abaa", true);
    addSample("bb",   true);

    addSample("abb",  false);
    addSample("b",    false);

    /* Other Samples
    // addSampleFromFile(|file:///home/orosu/Documents/workspaces/eclipse/Exbar/src/Exbar.rsc|, true);
    // addSampleFromDirectory(|file:///home/orosu/Documents/workspaces/eclipse/Exbar/src|, true);
    */

    // Build APTA
    buildAPTA();
}

/**
 * Add sample to set
 */
private void addSample(str sample, bool sampleType)
{
    if (sampleType == true) {
        positiveSamples += sample;
    } else {
        negativeSamples += sample;
    }
}

/**
 * Add Sample from file
 */
private void addSampleFromFile(loc fileLocation, bool sampleType)
{
    if (!exists(fileLocation)) {
        throw "File <fileLocation> does not exist!";
    }
    addSample(readFile(fileLocation), sampleType);
}

/**
 * Add Sample from directory
 */
private void addSampleFromDirectory(loc directoryLocation, bool sampleType)
{
    if (!isDirectory(directoryLocation)) {
        throw "Directory <directoryLocation> is not a directory!";
    }
    for (str entry <- listEntries(directoryLocation)) {
        if (isDirectory(directoryLocation + entry)) {
            addSampleFromDirectory(directoryLocation + entry, sampleType);
        } else {
            addSampleFromFile(directoryLocation + entry, sampleType);
        }
    }
}

/**
 * Build APTA
 */
private void buildAPTA()
{
    APTree tree0 = APTA::build(positiveSamples, negativeSamples);
    print("APTA"); iprintln(tree0);
}