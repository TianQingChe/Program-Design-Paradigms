import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.function.Supplier;

/**
 * Tests for Problem Set 10, Question 2.
 */
public class PdpQ2Tests {

    /**
     * List of Players
     */
    static Player p1;
    static Player p5;
    static Player p6;
    static Player p7;
    static Player p8;
    static Player p9;
    static Player p10;

    static void initPlayers() {
        p1 = Players.make("Player1");
        p5 = Players.make("Player5");
        p6 = Players.make("Player6");
        p7 = Players.make("Player7");
        p8 = Players.make("Player8");
        p9 = Players.make("Player9");
        p10 = Players.make("Player10");
    }
    
    /** Wraps the given actual thunk with initialization. */
    static <T> void addCase(PdpTestSuite tests, String name,
            Supplier<T> actualFn, T expected) {
        Supplier<T> a2 = () -> {
            initPlayers();
            return actualFn.get();
        };
        tests.addTestCase(name, a2, expected);
    }

    static Roster roster(Player... ps) {
        Roster r = Rosters.empty();
        for (Player p : ps) {
            r = r.with(p);
        }
        return r;
    }

    static <T> boolean giveEqualElements(Iterable<T> a, Iterable<T> b) {
        Iterator<T> it1 = a.iterator();
        Iterator<T> it2 = b.iterator();
        while (it1.hasNext() && it2.hasNext()) {
            if (!it1.next().equals(it2.next())) {
                return false;
            }
        }
        return it1.hasNext() == it2.hasNext();
    }

    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(15);

        addCase(tests, "empty rosters are equal", () -> {
            return Rosters.empty().equals(Rosters.empty());
        }, true);

        addCase(tests, "empty roster does not equal null", () -> {
            return Rosters.empty().equals(null);
        }, false);

        addCase(tests, "nonempty roster does not equal null", () -> {
            return roster(p10).equals(null);
        }, false);

        addCase(tests, "empty roster does not equal System.class", () -> {
            return Rosters.empty().equals(System.class);
        }, false);

        addCase(tests, "nonempty roster does not equal System.class", () -> {
            return roster(p10).equals(System.class);
        }, false);

        addCase(tests, "equals, same order, immutability", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p8, p9, p10);
            r3.with(p1); // no effect
            return r3.equals(r2);
        }, true);

        addCase(tests, "equals, different order", () -> {
            Roster r2 = roster(p9, p6, p8, p10, p7);
            Roster r3 = roster(p6, p7, p8, p9, p10);
            return r3.equals(r2);
        }, true);

        addCase(tests, "unequal rosters", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p5, p8, p9, p10);
            return r3.equals(r2) || r2.equals(r3);
        }, false);

        addCase(tests, "unequal rosters, one empty", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster();
            return r3.equals(r2) || r2.equals(r3);
        }, false);

        addCase(tests, "readyCount with redundant addition", () -> {
            Roster r2 = roster(p6, p7, p8, p5, p9, p8);
            return r2.readyCount();
        }, 5);

        addCase(tests, "readyCount after status change", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            p8.changeContractStatus(false);
            return r2.readyCount();
        }, 4);

        addCase(tests, "equals and readyCount after status change", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p8, p9, p10);
            p8.changeContractStatus(false);
            return r3.equals(r2) && r3.readyCount() == r2.readyCount();
        }, true);

        addCase(tests, "readyRoster equals partial roster", () -> {
            Roster r2 = roster(p6, p7, p9, p10);
            Roster r3 = r2.with(p8);
            r2.with(p1); // no effect
            p8.changeContractStatus(false);
            return r3.readyRoster().equals(r2);
        }, true);

        addCase(tests, "readyRosters are equal", () -> {
            Roster r2 = roster(p6, p7, p9, p10, p8);
            Roster r3 = roster(p9, p10, p6, p7, p8, p8, p10);
            p8.changeContractStatus(false);
            return r3.readyRoster().equals(r2.readyRoster());
        }, true);

        addCase(tests, "hashCode, empty rosters", () -> {
            return roster().hashCode() == roster().hashCode();
        }, true);

        addCase(tests, "hashCode, different order", () -> {
            Roster r2 = roster(p9, p6, p8, p10, p7);
            Roster r3 = roster(p6, p7, p8, p9, p10);
            return r3.hashCode() == r2.hashCode();
        }, true);

        addCase(tests, "hashCode, redundant addition", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p8, p9, p10, p6);
            return r3.hashCode() == r2.hashCode();
        }, true);

        addCase(tests, "hashCode, immutability", () -> {
            Roster r = roster(p1);
            int c = r.hashCode();
            r.with(p10).without(p1).with(p5);  // no effect
            return r.hashCode() == c;
        }, true);

        addCase(tests, "hashCode unaffected by player state", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            int oldHashCode = r2.hashCode();
            p8.changeContractStatus(false);
            p10.changeInjuryStatus(true);
            p7.changeSuspendedStatus(true);
            int newHashCode = r2.hashCode();
            return oldHashCode == newHashCode;
        }, true);

        addCase(tests, "toString(), one empty", () -> {
            Roster r2 = roster();
            Roster r3 = roster(p6, p7, p8, p9, p10, p5);
            return r2.toString().equals(r3.toString());
        }, false);

        addCase(tests, "toString(), two nonempty", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p8, p9, p10, p5);
            return r2.toString().equals(r3.toString());
        }, false);

        addCase(tests, "set size, immutability", () -> {
            Roster r2 = roster(p6, p7, p8, p8, p7);
            r2.with(p9);  // no effect
            r2.with(p10); // no effect
            return r2.size();
        }, 3);

        addCase(tests, "without()", () -> {
            Roster r2 = roster(p6, p7, p8, p9, p10);
            Roster r3 = roster(p6, p7, p8, p8)
                    .without(p7).with(p7)
                    .without(p9).with(p9)
                    .with(p10)
                    .with(p5).without(p5);
            return r2.size() == r3.size();
        }, true);

        addCase(tests, "nonempty roster without missing player", () -> {
            return roster(p9, p10).without(p5).size();
        }, 2);

        addCase(tests, "empty roster without missing player", () -> {
            return roster().without(p5).equals(roster());
        }, true);

        addCase(tests, "without, immutability", () -> {
            Roster r = roster(p7, p8);
            r.without(p7).without(p8);  // no effect
            return r.size();
        }, 2);

        addCase(tests, "has()", () -> {
            Roster r3 = roster(p6, p7, p8, p8)
                    .without(p7).with(p7)
                    .without(p9).with(p9)
                    .with(p10)
                    .with(p5).without(p5);
            return (!r3.has(p5) && r3.has(p9) && r3.has(p7) && r3.has(p9));
        }, true);

        addCase(tests, "empty roster has nothing", () -> {
            return Rosters.empty().has(p1);
        }, false);

        addCase(tests, "iterator over one player", () -> {
            Roster r = roster(p5);
            List<Player> expected = Arrays.asList(p5);
            return giveEqualElements(r, expected);
        }, true);

        addCase(tests, "iterator over multiple players", () -> {
            Player p11 = Players.make("AAA");
            Player p12 = Players.make("ABA");
            Player p13 = Players.make("BAB");
            Player p14 = Players.make("AAB");
            Player p15 = Players.make("BAA");
            Roster r1 = roster(p11, p12, p13, p14, p15);
            List<Player> expected = Arrays.asList(p11, p14, p12, p15, p13);
            return giveEqualElements(r1, expected);
        }, true);

        addCase(tests, "iterator with same name", () -> {
            Player p11 = Players.make("AAA");
            Player p12 = Players.make("ABA");
            Player p13 = Players.make("AAA");
            Player p14 = Players.make("AAB");
            Player p15 = Players.make("BAA");
            Roster r1 = roster(p11, p12, p13, p14, p15);
            List<Player> expected1 = Arrays.asList(p11, p13, p14, p12, p15);
            List<Player> expected2 = Arrays.asList(p13, p11, p14, p12, p15);
            return giveEqualElements(r1, expected1)
                    || giveEqualElements(r1, expected2);
        }, true);

        addCase(tests, "iterator and size for empty", () -> {
            Roster r0 = Rosters.empty();
            Iterator<Player> it = r0.iterator();
            return r0.size() == 0 && !it.hasNext();
        }, true);

        addCase(tests, "iterator, immutability", () -> {
            Roster r = roster(p8, p5, p6);
            r.with(p7).without(p5);  // no effect
            return giveEqualElements(r, Arrays.asList(p5, p6, p8));
        }, true);

        tests.runTests();
    }
}
