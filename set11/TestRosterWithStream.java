import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class TestRosterWithStream {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		TestRosterWithStream t=new TestRosterWithStream();
		Players factory=new Players();
		{// Test for RosterWithStream
	        Player p1=factory.make("David");
	        Player p2=factory.make("Messi");
	        Player p3=factory.make("Jackie");
	        Player p4=factory.make("Tom");
	        RosterWithStream r1=RosterWithStreams.empty().with(p1).with(p2).with(p3).with(p1);
	        RosterWithStream r2=r1.without(p1);
	        RosterWithStream r3=r2.with(p4);
	        RosterWithStream r4=r1.with(p1);
	        p1.changeContractStatus(false);
	        checkTrue(r1.readyRoster().equals(r1.without(p1).without(p1)),
	        		"The ready roster of r1 should be the same as r2");
	        checkTrue(numberEqual(r1.readyCount(),2),"The ready count of r1 should be 2");
	        checkTrue(stringEqual(r1.toString(),"3"),"The string should be 2");
	        checkFalse(r1.equals(2),"r1 should not equals a number 2");
	        checkFalse(r1.equals(r2),"The two rosters should not be the same");
	        checkFalse(r1.equals(r3),"The two rosters should not be the same");
	        checkFalse(numberEqual(r1.hashCode(),r2.hashCode()),
	        		"The two rosters' hashCode should not be the same");
	        checkTrue(numberEqual(r1.hashCode(),r4.hashCode()),
	        		"The two rosters' hashCode should be the same");
	        checkTrue(r1.equals(r1));
	        checkFalse(r1.equals(null));
		}
		{// Test for Player
			Player p1=factory.make("David");
			checkTrue(p1.available());
			checkTrue(p1.underContract());
	        checkFalse(p1.isInjured());
	        checkFalse(p1.isSuspended());
	        
	        p1.changeContractStatus(false);
	        checkFalse(p1.available());
	        
	        p1.changeContractStatus(true);
	        p1.changeInjuryStatus(true);
	        checkFalse(p1.available());
	        
	        p1.changeContractStatus(true);
	        p1.changeInjuryStatus(false);
	        p1.changeSuspendedStatus(true);
	        checkFalse(p1.available());
	        
	        checkTrue(stringEqual(p1.toString(),"David"));	   
		}
		{// Test for help functions
			checkFalse(numberEqual(1,2));
			checkFalse(numberEqual(1L,2L));
			checkTrue(false);
			checkFalse(true);
		}
		{// Test for stream
			Player p1=factory.make("David");
	        Player p2=factory.make("Messi");
	        Player p3=factory.make("Jackie");
	        Player p4=factory.make("Tom");
	        RosterWithStream r1=RosterWithStreams.empty().with(p1).with(p2).with(p3).with(p4);
	        RosterWithStream r2=r1.with(p4);
	        Predicate<Player> pre1=e->e.available();
	        
	        //allMatch
			checkTrue(r1.stream().allMatch(pre1),
					"All the elements in this stream should match the predicate");
			p1.changeContractStatus(false);
			checkFalse(r1.stream().allMatch(pre1),
					"At least one element in this stream should not match the predicate");
			
			//anyMatch
			checkTrue(r1.stream().anyMatch(pre1),
					"At least one element in this stream should match the predicate");
			p2.changeContractStatus(false);
			p3.changeContractStatus(false);
			p4.changeContractStatus(false);
			checkFalse(r1.stream().anyMatch(pre1),
					"All the elements in this stream should not match the predicate");
			
			//count
			checkTrue(numberEqual(r1.stream().count(),4L),"There should be 4 elements in this stream");
			
			//distinct
			checkTrue(r1.stream().distinct().collect(Collectors.toList())
					.equals(r2.stream().distinct().collect(Collectors.toList())),
					"The two streams should be the same after 'distinct' operation");
			
		    //filter
			p1.changeContractStatus(true);
			p2.changeContractStatus(true);
			checkTrue(r1.stream().filter(pre1).collect(Collectors.toList())
					.equals(r1.without(p3).without(p4).stream().collect(Collectors.toList())),
					"The stream should only have p1 and p2 after filtering unavailable players");
			
			//findAny
			checkTrue(r1.stream().findAny().get().equals(p1),"p1(David) should be found with findAny");
			
			//findFirst
			p1.changeContractStatus(false);
			p3.changeContractStatus(true);
			checkTrue(r1.stream().filter(pre1).findFirst().get().equals(p2),
					"p2(Messi) should be found with findFirst");
			
			//forEach
			List<String> names=new ArrayList();
			r1.stream().forEach(p->names.add(p.name()));
			List<String> result=Arrays.asList("David","Messi","Jackie","Tom");
			checkTrue(Arrays.equals(names.toArray(), result.toArray()),
					"This 'forEach' operation should constrcut an array of all players' names");
			
			//map
			String[] strA= {"DAVID","MESSI","JACKIE","TOM"};
			checkTrue(Arrays.equals(r1.stream()
					.map(p->p.name().toUpperCase()).toArray(), strA),
					"The 'map' operation should return a stream of strings in uppercase");
			
			//reduce
			checkTrue(Arrays.stream(strA)
					.reduce((player1,player2)-> player1+player2).get().equals("DAVIDMESSIJACKIETOM"),
					"The 'reduce' operation should return a string of all the players' names in uppercase");
			
			//skip
			checkTrue(Arrays
					.equals(r1.stream().skip(2).toArray(), r1.without(p1).without(p2).stream().toArray()),
					"The 'skip' operation should return a stream without the p1 and p1");
		}
		summarize();
	}
	
	private static int testsPassed = 0;
    private static int testsFailed = 0;

    private static final String FAILED
        = "    TEST FAILED: ";

    static boolean stringEqual(String str1, String str2) {
    	return str1.equals(str2);
    }
    static boolean numberEqual(int num1,int num2) {
    	return num1==num2;
    }
    static boolean numberEqual(long num1,long num2) {
    	return num1==num2;
    }
    static void checkTrue (boolean result) {
        checkTrue (result, "anonymous");
    }

    static void checkTrue (boolean result, String name) {
        if (result) {
            testsPassed = testsPassed + 1;
            // System.err.print(".");
        }        
        else {
            testsFailed = testsFailed + 1;
        }
    }

    static void checkFalse (boolean result) {
        checkFalse (result, "anonymous");
    }

    static void checkFalse (boolean result, String name) {
        checkTrue (! result, name);
    }

    static void summarize () {
        System.err.println ("Passed " + testsPassed + " tests");
        if (true) {
        }
    }
	
}
