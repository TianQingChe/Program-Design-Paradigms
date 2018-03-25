import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Tests for Problem Set 09, part 1.
 * 
 * Since question 1 was not very interesting, this class also tests
 * Competitor1.hasDefeated from question 2.
 */
public class PdpQ1Tests {
    
    public static boolean areSameCompetitor(Competitor c1, Competitor c2) {
        return c1.name().equals(c2.name());
    }

    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(60);
        
        /* Tests for Outcome implementations */
        
        Competitor y = new MockCompetitor("Y");
        Competitor z = new MockCompetitor("Z");
        
        tests.addTestCase("a Tie1 is a tie",
                () -> new Tie1(y, z).isTie(),
                true);
        
        tests.addTestCase("Tie1 - first/second 1",
                () -> {
                    Outcome o = new Tie1(y, z);
                    return areSameCompetitor(y, o.first())
                            || areSameCompetitor(y, o.second());
                },
                true);
        
        tests.addTestCase("Tie1 - first/second 2",
                () -> {
                    Outcome o = new Tie1(y, z);
                    return areSameCompetitor(z, o.first())
                            || areSameCompetitor(z, o.second());
                },
                true);
        
        tests.addTestCase("a Defeat1 is not a tie",
                () -> new Defeat1(y, z).isTie(),
                false);

        
        tests.addTestCase("Defeat1 - first/second 1",
                () -> {
                    Outcome o = new Defeat1(y, z);
                    return areSameCompetitor(y, o.first())
                            || areSameCompetitor(y, o.second());
                },
                true);
        
        tests.addTestCase("Defeat1 - first/second 2",
                () -> {
                    Outcome o = new Defeat1(y, z);
                    return areSameCompetitor(z, o.first())
                            || areSameCompetitor(z, o.second());
                },
                true);
        
        tests.addTestCase("Defeat1 - winner",
                () -> new Defeat1(y, z).winner().name(),
                y.name());
        
        tests.addTestCase("Defeat1 - loser",
                () -> new Defeat1(y, z).loser().name(),
                z.name());
        
        /* Tests for Competitor1.hasDefeated */
        
        tests.addTestCase("defeating via tie 1",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    Competitor C = new Competitor1("C");
                    return A.hasDefeated(B,
                        Arrays.asList(
                                new Tie1(A, B),
                                new Defeat1(B, A),
                                new Tie1(B, C)));
                },
                true);
        
        tests.addTestCase("defeating via tie 2",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    return A.hasDefeated(B,
                        Arrays.asList(
                                new Defeat1(B, A),
                                new Tie1(B, A)));
                },
                true);
        
        tests.addTestCase("no outcomes means no defeats",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    return A.hasDefeated(B, Collections.emptyList());
                },
                false);
        
        tests.addTestCase("no mentions means no defeats",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    Competitor C = new Competitor1("C");
                    Competitor D = new Competitor1("D");
                    return A.hasDefeated(B,
                        Arrays.asList(
                                new Tie1(C, D),
                                new Defeat1(D, C)));
                },
                false);
        
        tests.addTestCase("no such defeat",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    Competitor C = new Competitor1("C");
                    return A.hasDefeated(B,
                        Arrays.asList(
                                new Defeat1(A, C),
                                new Defeat1(B, C),
                                new Defeat1(C, A),
                                new Defeat1(C, B),
                                new Defeat1(B, A)));
                },
                false);
        
        tests.addTestCase("defeat is not transitive 1",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    Competitor C = new Competitor1("C");
                    Competitor D = new Competitor1("D");
                    return A.hasDefeated(B,
                        Arrays.asList(
                                new Tie1(A, D),
                                new Defeat1(C, B),
                                new Defeat1(B, A),
                                new Defeat1(A, C),
                                new Tie1(B, C)));
                },
                false);
        
        tests.addTestCase("defeat is not transitive 2",
                () -> {
                    Competitor A = new Competitor1("A");
                    Competitor B = new Competitor1("B");
                    Competitor C = new Competitor1("C");
                    return A.hasDefeated(C,
                        Arrays.asList(
                                new Tie1(A, B),
                                new Tie1(B, C)));
                },
                false);
        
        tests.runTests();
    }

    /**
     * MockCompetitor is a placeholder Competitor that allows us to test
     * the Outcome implementations independently of the Competitor
     * implementation.  Of the methods specified in the Competitor
     * interface, MockCompetitor supports only name().
     */
    private static class MockCompetitor implements Competitor {
        
        MockCompetitor(String name) {
            this.name = name;
        }

        @Override
        public String name() {
            return name;
        }

        @Override
        public boolean hasDefeated(Competitor c2, List<Outcome> outcomes) {
            throw new UnsupportedOperationException(
                    "MockCompetitor does not implement hasDefeated");
        }

        @Override
        public List<String> outranks(List<Outcome> outcomes) {
            throw new UnsupportedOperationException(
                    "MockCompetitor does not implement outranks");
        }

        @Override
        public List<String> outrankedBy(List<Outcome> outcomes) {
            throw new UnsupportedOperationException(
                    "MockCompetitor does not implement outrankedBy");
        }

        @Override
        public List<String> powerRanking(List<Outcome> outcomes) {
            throw new UnsupportedOperationException(
                    "MockCompetitor does not implement powerRanking");
        }
        
        private String name;
    }
}
