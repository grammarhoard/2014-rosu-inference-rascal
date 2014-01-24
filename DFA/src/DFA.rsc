/**
 * Deterministic Finite Automata (DFA) Module
 * DFA A = <Q, Z, d, s, F> where
 *     Q = finite non-empty set of states
 *     Sigma Z = finite non-empty set of input symbols (alphabet)
 *     delta d : Q x Z -> Q = transition function
 *     s (element of) Q = start state (initial "reset state) <=> q0
 *     F (subset of) Q = set of final states or accepting states of A
 * Built on APTA
 */
module DFA

import APTA;

/**
 * DFA A = <Q, Z, d, s, F>
 */
private data DFA = dfa();
anno tuple[
    set[str] Q, // set of states
    set[str] Z, // set of input symbols
    str(str nodeId, str edgeLabel) d, // transition function
    str s, // start state
    set[str] F // final states
] DFA@A;

/**
 * Build DFA from APTA
 */
public DFA build(APTA APTA)
{
    // Build DFA A
    /*
    set[str] Q, // set of states
    set[str] Z, // set of input symbols
    str(str nodeId, str edgeLabel) d, // transition function
    str s, // start state
    set[str] F // final states
    */
    DFA DFA = dfa();
    DFA@A = <
        {id | id <- APTA@redNodes + APTA@blueNodes},
        APTA@A.Z,
        APTA@A.d,
        APTA@A.s,
        {id | id <- APTA@redNodes, APTA@redNodes[id] != ""} +
            {id | id <- APTA@blueNodes, APTA@blueNodes[id] != ""}
    >;
    return DFA;
}