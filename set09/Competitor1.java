// Constructor template for Competitor1:
//     new Competitor1 (Competitor c1)
//
// Interpretation: the competitor represents an individual or team

// Note:  In Java, you cannot assume a List is mutable, because all
// of the List operations that change the state of a List are optional.
// Mutation of a Java list is allowed only if a precondition or other
// invariant says the list is mutable and you are allowed to change it.

import java.util.*;

// You may import other interfaces and classes here.

class Competitor1 implements Competitor {

    // You should define your fields here.
    String name;// the name of the current competitor
    
    Competitor1 (String s) {

        // Your code goes here.
        name=s;
    }

    // returns the name of this competitor

    public String name () {

        // Your code goes here.
        return name;
    }

    // GIVEN: another competitor and a list of outcomes
    // RETURNS: true iff one or more of the outcomes indicates this
    //     competitor has defeated or tied the given competitor

    public boolean hasDefeated (Competitor c2, List<Outcome> outcomes) {

        // Your code should replace the line below.
        for (Outcome o: outcomes) {
        	if (o.isTie()) {
        		if(o.first().equals(this) && o.second().equals(c2))
        			return true;
        		else if (o.first().equals(c2) && o.second().equals(this))
        			return true;
        	}
        	else {
        		if (o.winner().equals(this) && o.loser().equals(c2)) {
        			return true;
        		}
        	}
        }
        return false;
    }

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     the outcomes that are outranked by this competitor,
    //     without duplicates, in alphabetical order

    public List<String> outranks (List<Outcome> outcomes) {
    	List<Outcome> olForUse=cloneOutcomes(outcomes);
    	List<Competitor> cl=directLosers(this,olForUse);
    	olForUse.removeAll(directLosersOutcomes(this,olForUse));
    	
    	List<Competitor> resultComp=removeDuplicates(addIndirectLosers(cl,olForUse));
    	
    	List<String> result=new ArrayList<String>();
    	
    	for(Competitor c:resultComp) {
    		result.add(c.name());
    	}
    	
    	Comparator<String> alpha = (s1, s2) -> compare(s1, s2);
    	result.sort(alpha);
    	return result;
    }

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     the outcomes that outrank the current competitor,
    //     without duplicates, in alphabetical order

    public List<String> outrankedBy (List<Outcome> outcomes) {

        // Your code should replace the line below.
        List<Competitor> all=competitors(outcomes);
        List<String> result=new ArrayList();
        for(Competitor c:all) {
        	if(c.outranks(outcomes).contains(this.name())) {
        		result.add(c.name());
        	}
        }
        Comparator<String> alpha = (s1, s2) -> compare(s1, s2);
    	result.sort(alpha);
    	return result;
    }

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     one or more of the outcomes, without repetitions, with
    //     the name of competitor A coming before the name of
    //     competitor B in the list if and only if the power-ranking
    //     of A is higher than the power ranking of B.

    public List<String> powerRanking (List<Outcome> outcomes) {

        // Your code should replace the line below.
        List<Competitor> cs=competitors(outcomes);
    	Comparator<Competitor> power = (c1, c2) -> comparePowerRank(c2, c1,outcomes);
        cs.sort(power);
        List<String> result=new ArrayList();
        for(Competitor c:cs) {
        	result.add(c.name());
        }
        return result;
    }

    // You may define help methods here.
    // You may also define a main method for testing.
    
    // GIVEN: a list of competitors which are defeated or tied by this competitor,
    //        and a list of outcomes only contain competitors that are not defeated and not tied by it
    // RETURNS: a list of all the competitors that are outranked by the competitor(all the competitors
    //          that are indirectly outranked by the competitor have been added to the list in this 
    //          function)
    
    static List<Competitor> addIndirectLosers(List<Competitor> competitors, List<Outcome> outcomes){
    	while(!noIndirectLoser(competitors,outcomes)) {
    		List<Competitor> temp=cloneCompetitors(competitors);
    		competitors.addAll(indirectLosers(competitors,outcomes));
    		outcomes.removeAll(indirectLoserOutcomes(temp,outcomes));
    	}
    	return removeDuplicates(competitors);
    }
    static List<Competitor> cloneCompetitors(List<Competitor> cs){
    	List<Competitor> result=new ArrayList();
    	for(Competitor c:cs) {
    		result.add(new Competitor1(c.name()));
    	}
    	return result;
    }
    
    // GIVEN: a list of competitors cl which are outranked by this competitor,
    //        and a list of outcomes ol only  contain comeptitors that are not put to cl yet
    // RETURNS: a list of competitors from outcomes which are defeated or tied by the competitors
    //          in cl
    
    static List<Competitor> indirectLosers(List<Competitor> competitors, List<Outcome> outcomes){
    	List<Outcome> ol=indirectLoserOutcomes(competitors,outcomes);
    	List<Competitor> cl=new ArrayList<Competitor>();
    	
    	for(Outcome o:ol) {
    		if(!o.isTie()) {
    			cl.add(o.loser());
    		}
    		else {
    			if (competitors.contains(o.first()))
    				cl.add(o.second());
    			else cl.add(o.first());
    		}
    	}
    	
    	return cl;
    }
    
    // GIVEN: a list of competitors cl which are outranked by this competitor,
    //        and a list of outcomes ol only  contain comeptitors that are not put to cl yet
    // RETURNS: a list of outcomes from ol whose competitors are defeated or tie by the competitors
    //          in cl
    
    static List<Outcome> indirectLoserOutcomes(List<Competitor> competitors, List<Outcome> outcomes){
    	List<Outcome> result=new ArrayList();
    	for(Outcome o:outcomes) {
    		if(containIndirectLoser(o,competitors)) {
    			result.add(o);
    		}
    	}
    	return result;
    }
    
    // GIVEN: an outcome and a list of competitors cl
    // RETURNS: true if there is a competitor from cl that is the winner in the outcome(means
    //          another competitor in the outcome is a loser)
    
    static boolean containIndirectLoser(Outcome o,List<Competitor> competitors) {
    	for(int i=0;i<competitors.size();i++) {
    		if(containWinner(competitors.get(i),o))
    			return true;
    	}
    	return false;
    }
    
    // GIVEN: a list of competitors cl and a list of outcomes ol
    // RETURNS: true if ol contains no indirect loser
        
    static boolean noIndirectLoser(List<Competitor> competitors, List<Outcome> outcomes) {
    	for (Outcome o: outcomes) {
    		if(o.isTie()) {
    			if(competitors.contains(o.first()) || competitors.contains(o.second()))
    				return false;
    		}
    		else {
    			if(competitors.contains(o.winner()))
    				return false;
    		}
    	}
    	return true;
    }
    
    // GIVEN: a competitor c and a list of outcomes ol
    // RETURNS: a list of competitors from ol which are defeated or tied by c
    //          including c itself if c is outranked by itself
    
    static List<Competitor> directLosers(Competitor c, List<Outcome> outcomes){
    	List<Competitor> cl=directLosers2(c,outcomes);
    	if(outrankedBySelf(c,outcomes)) {
    		cl.add(c);
    	}
    	return cl;
    }
    
    // GIVEN: a competitor c and a list of outcomes ol
    // RETURNS: true if c is tied in at least one outcome in ol
    
    static boolean outrankedBySelf(Competitor c, List<Outcome> outcomes) {
    	for(Outcome o:outcomes) {
    		if(o.isTie() && (o.first().equals(c) || o.second().equals(c)))
    			return true;
    	}
    	return false;
    }
    
    // GIVEN: a competitor c and a list of outcomes ol
    // RETURNS: a list of competitors from ol which are defeated or tied by c
    
    static List<Competitor> directLosers2(Competitor c, List<Outcome> outcomes){
    	List<Outcome> ol=directLosersOutcomes(c,outcomes);
    	List<Competitor> cl=new ArrayList<Competitor>();
    	for(Outcome o:ol) {
    		cl.add(loser(c,o));
    	}
    	return cl;
    }
    
    // GIVEN: a competitor c and a list of outcomes ol
    // RETURNS: a list of outcomes from ol which contain competitors defeated or tied by c
    
    static List<Outcome> directLosersOutcomes(Competitor c,List<Outcome> outcomes){
    	List<Outcome> result=new ArrayList();
    	for(Outcome o:outcomes) {
    		if(containWinner(c,o)) {
    			result.add(o);
    		}
    	}
    	return result;
    }
    
    // GIVEN: a competitor c and an outcome o
    // RETURNS: true if c is the winner in o
    
    static boolean containWinner(Competitor c,Outcome o) {
    	if (o.isTie()) {
    		return (o.first().equals(c) || o.second().equals(c));
    	}
    	else {
    		return o.winner().equals(c);
    	}
    }
    
    // GIVEN: a competitor c and an outcome o
    // RETURNS: another competitor
    
    static Competitor loser(Competitor c, Outcome o){
    	if(o.isTie()) {
    		if(o.first().equals(c))  
    		 return o.second();
    		else return o.first();
    	}
    	else {
    		return o.loser();
    	}
    }
    
    // GIVEN: a list of competitors ol
    // RETURNS: ol after removing duplicate competitors in it
    
    static List<Competitor> removeDuplicates(List<Competitor> cs){
    	List<String> strs=new ArrayList();
    	for(int i=0;i<cs.size();i++) {
    		strs.add(cs.get(i).name());
    	}
    	List<String> newStrs=new ArrayList(new HashSet(strs));
    	List<Competitor> result=new ArrayList();
    	for(int i=0;i<newStrs.size();i++) {
    		Competitor c=new Competitor1(newStrs.get(i));
    		result.add(c);
    	}
    	return result;
    }
    
    // GIVEN: a list of outcomes
    // RETURNS: all competitors from the outcomes(after removing duplicates)
    
    private List<Competitor> competitors(List<Outcome> outcomes){
    	List<Competitor> cs=new ArrayList();
    	for(Outcome o:outcomes) {
    		cs.add(o.first());
    		cs.add(o.second());
    	}
    	
    	return removeDuplicates(cs);
    }
    // GIVEN: a list of outcomes
    // RETURNS: another list of outcomes which is the same as the given one
    
    private List<Outcome> cloneOutcomes(List<Outcome> outcomes){
    	List<Outcome> newOl=new ArrayList();
    	for(Outcome o:outcomes) {
    		Outcome newO=cloneOutcome(o);
    		newOl.add(newO);
    	}
    	return newOl;
    }
    
    // GIVEN: an outcome
    // RETURNS: another outcome which is the same as the given one
    
    private Outcome cloneOutcome(Outcome o) {
    	if(o.isTie()) {
    		String s1=o.first().name();
    		String s2=o.second().name();
    		return new Tie1(new Competitor1(s1),new Competitor1(s2));
    	}
    	else {
    		String s1=o.first().name();
    		String s2=o.second().name();
    		return new Defeat1(new Competitor1(s1),new Competitor1(s2));
    	}
    }
    
    // GIVEN: a string a and a string b
    // RETURNS: 0 if the two strings are alphabetically equal,
    //          a negative integer if a is alphabetically smaller than b
    //          a positive integer if a is alphabetically bigger than b
    
    private int compare(String a, String b) {
    	return a.compareTo(b);
    }
    
    // GIVEN: a competitor c1, another competitor c2 and a list of outcomes contains c1 and c2
    // RETURNS: 1 if c1 has higher power rank than c2
    //          -1 if c1 has the same or lower power rank compared to c2
    
    static int comparePowerRank(Competitor c1,Competitor c2,List<Outcome> outcomes) {
    	int c1outranked=c1.outrankedBy(outcomes).size();
    	int c2outtanked=c2.outrankedBy(outcomes).size();
    	int c1outranks=c1.outranks(outcomes).size();
    	int c2outranks=c2.outranks(outcomes).size();
    	double c1nonLosing=nonLosingPercentage(c1,outcomes);
    	double c2nonLosing=nonLosingPercentage(c2,outcomes);
    	if(c1outranked<c2outtanked) return 1;
    	else if(c1outranked==c2outtanked && c1outranks>c2outranks) return 1;
    	else if(c1outranked==c2outtanked && c1outranks==c2outranks && c1nonLosing>c2nonLosing)
    		return 1;
    	else if(c1outranked==c2outtanked && c1outranks==c2outranks && c1nonLosing==c2nonLosing && stringCompare(c1.name(),c2.name()))
    		return 1;
    	else return -1;
    }
    
    // GIVEN: a string s1 and another string s2
    // RETURNS: true if  s1 is alphabetically smaller than s2
    
    static boolean stringCompare(String s1,String s2) {
		if(s1.compareTo(s2)<0) return true;
		else return false;
	}
    
    // GIVEN: a competitor c and a list of outcomes contains c
    // RETURNS: the non-losing percentage of c
    
    static double nonLosingPercentage(Competitor c,List<Outcome> outcomes) {
    	double nonLosing=(double)nonLosingOutcomes(c,outcomes);
    	double mention=(double)mentionOutcomes(c,outcomes);
    	double result=nonLosing/mention;
    	return result;
    }
    
    // GIEVN: a competitor c and a list of outcomes contains c
    // RETURNS: the number of outcomes containing c as winner
    
    static int nonLosingOutcomes(Competitor c,List<Outcome> outcomes){
    	List<Outcome> result=new ArrayList();
    	for(Outcome o:outcomes) {
    		if(o.isTie()) {
    			if(o.first().equals(c) || o.second().equals(c))
    				result.add(o);
    		}
    		else{
    			if(o.winner().equals(c))
    				result.add(o);
    		}
    	}
    	return result.size();
    }
    
    // GIVEN: a competitor c and a list of outcomes contains c
    // RETURNS: the number of outcomes mention c
    
    static int mentionOutcomes(Competitor c,List<Outcome> outcomes){
    	List<Outcome> result=new ArrayList();
    	for(Outcome o:outcomes) {
    		if(o.first().equals(c) || o.second().equals(c))
    			result.add(o);
    	}
    	return result.size();
    }
    
    // GIVEN: an object c
    // RETURN: true if c equals this competitor
    @Override
	public boolean equals(Object c) {
		// TODO Auto-generated method stub
		if(c==null) return false;
		if(this==c) return true;
		if(c instanceof Competitor) {
			Competitor comp=(Competitor)c;
			if(comp.name()==this.name()) {
				return true;
			}
			else return false;
		}
		return false;
	}
    
    // a main method for unit testing
    public static void main(String[] args) {
    	CompetitorTest c=new CompetitorTest();
    	CompetitorTest.main(args);
    }
}

// Unit tests for Competitor1
class CompetitorTest{
    public static void main(String[] args) {
    	Competitor a=new Competitor1("A");
    	Competitor b=new Competitor1("B");
    	Competitor c=new Competitor1("C");
    	Competitor d=new Competitor1("D");
    	Competitor e=new Competitor1("E");
    	Competitor f=new Competitor1("F");
    	Competitor g=new Competitor1("G");
    	Competitor h=new Competitor1("H");
    	
    	checkTrue(a.name().equals("A"));    
    	
    	checkFalse(a.equals(null));
    	checkFalse(a.equals(new String("C")));
    
    	checkTrue(Competitor1.stringCompare("A","B"));
    	checkFalse(Competitor1.stringCompare("B","A"));
    	
    	checkTrue(numberEqual(1,1));
    	checkFalse(numberEqual(1,-1));
    	
    	{//Test for hasDefeated 
    		Outcome o1=new Defeat1(a,b);
    		Outcome o2=new Tie1(b,c);
    		Outcome o3=new Tie1(e,f);
    		List<Outcome> outcomes=new ArrayList();
    		o2.winner();o2.loser();
    		outcomes.add(o1);outcomes.add(o2);outcomes.add(o3);
    		
    		checkTrue(a.hasDefeated(b, outcomes));
    		checkFalse(a.hasDefeated(c, outcomes));
    		checkFalse(b.hasDefeated(a, outcomes));
    		checkTrue(b.hasDefeated(c, outcomes));
    		checkTrue(c.hasDefeated(b, outcomes));
    		checkFalse(c.hasDefeated(a, outcomes));
    		checkFalse(e.hasDefeated(b, outcomes));
    	}
    	
    	{//Test for outranks and outrankedBy
    		Outcome o1=new Defeat1(a,b); Outcome o2=new Tie1(b,c);
    		List<Outcome> os1=new ArrayList();os1.add(o1);os1.add(o2);
    		List<String> strs1=Arrays.asList("B","C");
    		checkTrue(stringListEqual(a.outranks(os1),strs1));
    		
    		Outcome o3=new Defeat1(b,a);
    		List<Outcome> os2=new ArrayList();os2.add(o1);os2.add(o3);
    		List<String> strs2=Arrays.asList("A","B");
    		checkTrue(stringListEqual(b.outranks(os2),strs2));
    		checkTrue(stringListEqual(c.outranks(os1),strs1));
    		
    		List<String> strs3=new ArrayList();
    		checkTrue(stringListEqual(a.outrankedBy(os1),strs3));
    		checkTrue(stringListEqual(b.outrankedBy(os2),strs2));
    		
    		List<String> strs4=Arrays.asList("A","B","C");
    		checkTrue(stringListEqual(c.outrankedBy(os1),strs4));
    	}
//    	
    	{//Test for powerRanking
    		{
    		Outcome o1=new Defeat1(a,d);
    		Outcome o2=new Defeat1(a,e);
    		Outcome o3=new Defeat1(c,b);
    		Outcome o4=new Defeat1(c,f);
    		Outcome o5=new Tie1(d,b);
    		Outcome o6=new Defeat1(f,e);
    		List<Outcome> os=new ArrayList();
    		os.add(o1);os.add(o2);os.add(o3);
    		os.add(o4);os.add(o5);os.add(o6);
    		List<String> strs=Arrays.asList("C","A","F","E","B","D");
    		checkTrue(stringListEqual(a.powerRanking(os),strs));
    		}
    		
    		{
    			Outcome o1=new Defeat1(c,a);Outcome o2=new Defeat1(c,b);
        		Outcome o3=new Defeat1(a,d);
        		List<Outcome> os=new ArrayList();
        		os.add(o1);os.add(o2);os.add(o3);
        		List<String> strs=Arrays.asList("C","A","B","D");
        		checkTrue(stringListEqual(a.powerRanking(os),strs));
    		}
    		
    		{
    			Outcome o1=new Defeat1(c,a);Outcome o2=new Defeat1(c,d);
    			Outcome o3=new Defeat1(b,c);Outcome o4=new Defeat1(e,d);
    			Outcome o5=new Defeat1(a,f);Outcome o6=new Defeat1(d,g);
    			List<Outcome> os=new ArrayList();
    			os.add(o1);os.add(o2);os.add(o3);
    			os.add(o4);os.add(o5);os.add(o6);
    			List<String> strs=Arrays.asList("B","E","C","A","D","F","G");
        		checkTrue(stringListEqual(a.powerRanking(os),strs));
    		}
    		
    		{//Test for comparePowerRank
        		Outcome o1=new Defeat1(c,a);Outcome o2=new Defeat1(h,d);
    			Outcome o3=new Defeat1(b,c);Outcome o4=new Defeat1(e,d);
    			Outcome o5=new Defeat1(a,f);Outcome o6=new Defeat1(d,g);
    			List<Outcome> os=new ArrayList();
    			os.add(o1);os.add(o2);os.add(o3);
    			os.add(o4);os.add(o5);os.add(o6);
    			List<String> strs=Arrays.asList("B","E","H","C","A","D","F","G");
        		checkTrue(stringListEqual(a.powerRanking(os),strs));
        		
        		Outcome newO3=new Defeat1(b,a);
        		List<Outcome> os2=new ArrayList();
        		os2.add(o1);os2.add(o2);os2.add(newO3);
        		os2.add(o4);os2.add(o5);os2.add(o6);
        		List<String> strs1=Arrays.asList("B","C","E","H","A","D","F","G");
        		checkTrue(stringListEqual(a.powerRanking(os2),strs1));
        	}
    	}
//    	
    	{//Test for stringListEqual
    		List<String> sl1=Arrays.asList("A","B","C");
    		List<String> sl2=Arrays.asList("A","E","C");
    		List<String> sl3=Arrays.asList("A","E");
    		checkFalse(stringListEqual(sl1,sl2));
    		checkFalse(stringListEqual(sl1,sl3));
    	}
    	
    	{//Test for comparePowerRank
    		Outcome o1=new Defeat1(c,a);Outcome o2=new Defeat1(h,d);
			Outcome o3=new Defeat1(b,c);Outcome o4=new Defeat1(e,d);
			Outcome o5=new Defeat1(a,f);Outcome o6=new Defeat1(d,g);
			List<Outcome> os=new ArrayList();
			os.add(o1);os.add(o2);os.add(o3);
			os.add(o4);os.add(o5);os.add(o6);
    		checkTrue(numberEqual(Competitor1.comparePowerRank(a,d,os),1));
    		checkTrue(numberEqual(Competitor1.comparePowerRank(d,a,os),-1));
    		
    		Outcome newO3=new Defeat1(b,a);
    		List<Outcome> os2=new ArrayList();
    		os2.add(o1);os2.add(o2);os2.add(newO3);
    		os2.add(o4);os2.add(o5);os2.add(o6);
    		checkTrue(numberEqual(Competitor1.comparePowerRank(a,d,os2),1));
    		checkTrue(numberEqual(Competitor1.comparePowerRank(d,a,os2),-1));
    	}
    	checkTrue(false);
    	checkFalse(true);
    	
    	summarize();
    	testsFailed = 0;
    	summarize();
    }
    public static boolean numberEqual(int a,int b) {
    	if(a==b)return true;
    	else return false;
    }
    public static boolean stringListEqual(List<String> sl1,List<String> sl2) {
    	if(sl1.size()==sl2.size()) {
    		for(int i=0;i<sl1.size();i++) {
    			if(!sl1.get(i).equals(sl2.get(i)))
    				return false;
    		}
    	}
    	else {
    		return false;
    	}
    	return true;
    }
    private static int testsPassed = 0;
    private static int testsFailed = 0;

    private static final String FAILED
        = "    TEST FAILED: ";

    static void checkTrue (boolean result) {
        checkTrue (result, "anonymous");
    }

    static void checkTrue (boolean result, String name) {
        if (result)
            testsPassed = testsPassed + 1;
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
        if (testsFailed > 0) {
            
        }
    }
}
