import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Tests for Problem Set 09, part 2.
 */
public class PdpQ2Tests {

    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(60);
        
        /* Tests for Competitor1.outranks and outrankedBy */
        
        tests.addTestCase("outranks - simple cycle",
                () -> competitor("A").outranks(list(
                        defeated("C", "B"),
                        defeated("B", "A"),
                        defeated("A", "C"),
                        tie("B", "C"))),
                list("A", "B", "C"));
        
        tests.addTestCase("A outranks B and D transitively",
                () -> competitor("A").outranks(list(
                        defeated("C", "B"),
                        defeated("A", "C"),
                        tie("B", "D"))),
                list("B", "C", "D"));
        
        tests.addTestCase("E does not outrank anyone",
                () -> competitor("E").outranks(list(
                        defeated("C", "E"),
                        defeated("B", "C"),
                        tie("B", "D"),
                        tie("D", "B"))),
                list());
        
        tests.addTestCase("outranks - cycle with a tie",
                () -> competitor("A").outranks(list(
                        defeated("A", "B"),
                        defeated("B", "C"),
                        defeated("C", "D"),
                        defeated("D", "E"),
                        tie("A", "E"))),
                list("A", "B", "C", "D", "E"));
        
        tests.addTestCase("outrankedBy - small cycle",
                () -> competitor("C").outrankedBy(list(
                        defeated("A", "B"),
                        defeated("B", "C"),
                        defeated("C", "D"),
                        defeated("D", "E"),
                        tie("C", "E"))),
                list("A", "B", "C", "D", "E"));
        
        tests.addTestCase("outrankedBy - A is undefeated",
                () -> competitor("A").outrankedBy(list(
                        defeated("A", "B"),
                        defeated("B", "C"),
                        defeated("C", "D"),
                        defeated("D", "E"),
                        tie("C", "E"))),
                list());
        
        tests.addTestCase("outrankedBy - F is undefeated",
                () -> competitor("F").outrankedBy(list(
                        defeated("B", "C"),
                        defeated("C", "E"),
                        defeated("E", "L"),
                        defeated("F", "K"),
                        defeated("G", "K"),
                        defeated("J", "L"),
                        defeated("K", "B"),
                        defeated("L", "P"),
                        defeated("P", "B"),
                        tie("C", "E"))),
                list());

        tests.addTestCase("outranks - multiple cycles 1",
                () -> competitor("F").outranks(list(
                        defeated("B", "C"),
                        defeated("C", "E"),
                        defeated("E", "L"),
                        defeated("F", "K"),
                        defeated("G", "K"),
                        defeated("J", "L"),
                        defeated("K", "B"),
                        defeated("L", "P"),
                        defeated("P", "B"),
                        tie("C", "E"))),
                list("B", "C", "E", "K", "L", "P"));

        tests.addTestCase("outranks - multiple cycles 2",
                () -> competitor("E").outranks(list(
                        defeated("B", "C"),
                        defeated("C", "E"),
                        defeated("E", "L"),
                        defeated("F", "K"),
                        defeated("G", "K"),
                        defeated("J", "L"),
                        defeated("K", "B"),
                        defeated("L", "P"),
                        defeated("P", "B"),
                        tie("C", "E"),
                        tie("J", "P"))),
                list("B", "C", "E", "J", "L", "P"));
        
        tests.addTestCase("outrankedBy - self-outrank due to tie",
                () -> competitor("F").outrankedBy(list(
                        tie("G", "K"),
                        defeated("K", "B"),
                        tie("F", "K"))),
                list("F", "G", "K"));
        
        /* Tests for Competitor1.powerRanking */
        
        tests.addTestCase("C has higher non-losing percentage than A",
                () -> competitor("X").powerRanking(list(
                        defeated("B", "C"),
                        defeated("C", "B"),
                        tie("A", "B"),
                        tie("A", "C"),
                        defeated("C", "A"))),
                list("C", "A", "B"));
        
        tests.addTestCase("powerRanking - multiple cycles (defeats+ties)",
                () -> competitor("X").powerRanking(list(
                        defeated("A", "B"),
                        tie("B", "C"),
                        tie("D", "E"),
                        defeated("E", "H"),
                        tie("F", "I"),
                        defeated("H", "L"),
                        defeated("I", "M"),
                        tie("J", "N"),
                        defeated("K", "O"),
                        tie("L", "P"),
                        defeated("M", "K"),
                        tie("P", "B"),
                        tie("C", "E"),
                        tie("J", "P"))),
                list("A", "F", "I", "M", "K", "O", "C", "D",
                        "E", "J", "N", "P", "B", "H", "L"));
        
        tests.addTestCase("E has the highest non-losing percentage",
                () -> competitor("X").powerRanking(list(
                        tie("A", "E"),
                        defeated("C", "B"),
                        defeated("B", "A"),
                        defeated("A", "C"),
                        tie("B", "C"))),
                list("E", "A", "B", "C"));
        
        tests.addTestCase("alphabetical order gets precedence",
                () -> competitor("X").powerRanking(list(
                        defeated("C", "E"),
                        defeated("D", "C"),
                        tie("D", "B"))),
                list("B", "D", "C", "E"));
        
        tests.addTestCase("powerRanking - multiple cycles (defeats only)",
                () -> competitor("X").powerRanking(list(
                        defeated("A", "B"),
                        defeated("B", "C"),
                        defeated("C", "D"),
                        defeated("D", "E"),
                        defeated("E", "H"),
                        defeated("F", "I"),
                        defeated("I", "M"),
                        defeated("M", "K"),
                        defeated("N", "L"),
                        defeated("O", "A"),
                        defeated("P", "B"),
                        tie("C", "E"))),
                list("O", "P", "F", "N", "A", "I", "L", "M", "B",
                        "K", "C", "E", "D", "H"));

        tests.runTests();
    }
    
    /**
     * Here we use our own implementation of Outcome to make sure students
     * code to the interface, not the implementation.
     */
    private static class MockOutcome implements Outcome {
        
        MockOutcome(boolean tie, Competitor first, Competitor second) {
            this.tie = tie;
            this.winner = first;
            this.loser = second;
        }

        @Override
        public boolean isTie() {
            return tie;
        }

        @Override
        public Competitor first() {
            return loser;
        }

        @Override
        public Competitor second() {
            return winner;
        }

        @Override
        public Competitor winner() {
            return winner;
        }

        @Override
        public Competitor loser() {
            return loser;
        }
        
        private boolean tie;
        private Competitor winner;
        private Competitor loser;
    }
    
    private static Outcome tie(String c1, String c2) {
        return new MockOutcome(true, competitor(c1), competitor(c2));
    }
    
    private static Outcome defeated(String c1, String c2) {
        return new MockOutcome(false, competitor(c1), competitor(c2));
    }
    
    @SafeVarargs
    public static <T> List<T> list(T... a) {
        return Arrays.asList(a);
    }
    
    private static Competitor competitor(String c) {
        if (!competitors.containsKey(c)) {
            competitors.put(c, new Competitor1(c));
        }
        return competitors.get(c);
    }

    private static Map<String, Competitor> competitors = new HashMap<>();
}
