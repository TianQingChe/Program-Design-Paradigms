import java.lang.ref.PhantomReference;

/**
 * Tests for Problem Set 10, Question 1.
 */
public class PdpQ1Tests {

    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(15);

        tests.addTestCase("initial availability", () -> {
            Player p1 = Players.make("Morris, Alfred");
            return p1.available() && !p1.isInjured() && !p1.isSuspended()
                    && p1.underContract();
        }, true);

        tests.addTestCase("changeContractStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeContractStatus(false);
            return !p1.available() && !p1.isInjured() && !p1.isSuspended()
                    && !p1.underContract();
        }, true);

        tests.addTestCase("changeContractStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeContractStatus(false);
            p1.changeContractStatus(true);
            return p1.available() && !p1.isInjured() && !p1.isSuspended()
                    && p1.underContract();
        }, true);

        tests.addTestCase("changeInjuryStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeInjuryStatus(true);
            return !p1.available() && p1.isInjured() && !p1.isSuspended()
                    && p1.underContract();
        }, true);

        tests.addTestCase("changeInjuryStatus and changeContractStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeInjuryStatus(true);
            p1.changeContractStatus(false);
            return !p1.available() && p1.isInjured() && !p1.isSuspended()
                    && !p1.underContract();
        }, true);

        tests.addTestCase("changeInjuryStatus and changeSuspendedStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeInjuryStatus(true);
            p1.changeSuspendedStatus(true);
            p1.changeInjuryStatus(true);
            p1.changeSuspendedStatus(true);
            return !p1.available() && p1.isInjured() && p1.isSuspended()
                    && p1.underContract();
        }, true);

        tests.addTestCase("changeSuspendedStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeSuspendedStatus(true);
            return !p1.available() && !p1.isInjured() && p1.isSuspended()
                    && p1.underContract();
        }, true);

        tests.addTestCase("changeContractStatus and changeSuspendedStatus", () -> {
            Player p1 = Players.make("Player 1");
            p1.changeSuspendedStatus(true);
            p1.changeContractStatus(false);
            return !p1.available() && !p1.isInjured() && p1.isSuspended()
                    && !p1.underContract();
        }, true);

        tests.addTestCase("one player, one name", () -> {
            Player p1 = Players.make("Player 1");
            return p1.name().equals("Player 1");
        }, true);

        tests.addTestCase("two players, two names", () -> {
            Player p1 = Players.make("Player A");
            Player p2 = Players.make("Player B");
            return p1.name().equals(p2.name());
        }, false);

        tests.addTestCase("true equals", () -> {
            Player p1 = Players.make("Player 1");
            return p1.equals(p1);
        }, true);

        tests.addTestCase("two players with same name are not equal", () -> {
            Player p1 = Players.make("Player 1");
            Player p2 = Players.make("Player 1");
            return p1.equals(p2);
        }, false);

        tests.addTestCase("two players with diff name are not equal", () -> {
            Player p1 = Players.make("Bar");
            Player p2 = Players.make("Baz");
            return p1.equals(p2);
        }, false);

        tests.addTestCase("player does not equal null", () -> {
            Player p1 = Players.make("Player 1");
            return p1.equals(null);
        }, false);

        tests.addTestCase("player does not equal non-player", () -> {
            Player p1 = Players.make("Player 1");
            return p1.equals(PhantomReference.class);
        }, false);

        tests.addTestCase("hashCode and contract status", () -> {
            Player p1 = Players.make("Player 1");
            int origHashCode = p1.hashCode();
            p1.changeContractStatus(false);
            return p1.hashCode() == origHashCode;
        }, true);

        tests.addTestCase("hashCode and injury status", () -> {
            Player p1 = Players.make("Player 1");
            int origHashCode = p1.hashCode();
            p1.changeInjuryStatus(true);
            return p1.hashCode() == origHashCode;
        }, true);

        tests.addTestCase("hashCode and suspended status", () -> {
            Player p1 = Players.make("Player 1");
            int origHashCode = p1.hashCode();
            p1.changeSuspendedStatus(true);
            return p1.hashCode() == origHashCode;
        }, true);

        tests.addTestCase("toString", () -> {
            Player p1 = Players.make("Player 1");
            Player p2 = Players.make("Player 2");
            return p1.toString().equals(p2.toString());
        }, false);

        tests.runTests();
    }

}
