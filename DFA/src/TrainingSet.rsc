/**
 * Training Set Module
 * Set of pairs (tuples) T = {<s1, l1>, ..., <sm, lm>},
 *    where each pair <si, li> is one input string and its label (output)
 * E.g. T = {<1, true>, <11, true>, <0, false>, <101, false>}
 * The first two tuples are positive samples and the last two are negative
 */
module TrainingSet

import IO;

/**
 * Training Set T = {<s1, l1>, ..., <sm, lm>}
 */
private data TrainingS = trainingSet();
anno set[tuple[str, bool]] TrainingS@T;

/**
 * Set of samples
 */
private set[tuple[str, bool]] trainingSet0 = {};

/**
 * Build Training Set
 */
public TrainingS build()
{
    TrainingS trainingSet = trainingSet();
    trainingSet@T = trainingSet0;
    return trainingSet;
}

/**
 * Add sample to Training Set
 */
public void addSample(str sample, bool sampleType)
{
    trainingSet0 += <sample, sampleType>;
}

/**
 * Add Sample from file
 */
public void addSampleFromFile(loc fileLocation, bool sampleType)
{
    if (!exists(fileLocation)) {
        throw "File <fileLocation> does not exist!";
    }
    addSample(readFile(fileLocation), sampleType);
}

/**
 * Add Sample from directory
 */
public void addSampleFromDirectory(loc directoryLocation, bool sampleType)
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
