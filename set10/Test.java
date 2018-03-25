import java.util.*;

public class Test {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Test t=new Test();
		{// Test for Roster
	        Player p1=Players.make("David");
	        Player p2=Players.make("Messi");
	        Player p3=Players.make("Jackie");
	        Player p4=Players.make("Tom");
	        Roster r1=Rosters.empty().with(p1).with(p2).with(p3).with(p1);
	        Roster r2=r1.without(p1);
	        Roster r3=r2.with(p4);
	        p1.changeContractStatus(false);
	        checkTrue(r1.readyRoster().equals(r1.without(p1).without(p1)),"The ready roster of r1 should be the same as r2");
	        checkTrue(numberEqual(r1.readyCount(),2),"The ready count of r1 should be 2");
	        Iterator<Player> i=r1.iterator();
	        while(i.hasNext())
	        	i.next();
	        checkTrue(stringEqual(r1.toString(),"3"));
	        checkFalse(r1.equals(2));
	        checkFalse(r1.equals(r2));
	        checkFalse(r1.equals(r3));
		}
		{// Test for Player
			Player p1=Players.make("David");
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
			checkTrue(false);
			checkFalse(true);
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
