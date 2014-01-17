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
    addSample("1",    true);
    addSample("11",   true);
    addSample("1111", true);

    addSample("0",    false);
    addSample("101",  false);

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
 * Build APTA
 */
private void buildAPTA()
{
    APTree tree0 = APTA::build(positiveSamples, negativeSamples);
    print("APTA"); iprintln(tree0);
}