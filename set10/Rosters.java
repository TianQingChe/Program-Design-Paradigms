import java.util.*;
import java.util.stream.Stream;

//A Roster is an object of any class that implements the Roster interface.
//
// A Roster object represents a set of players.
//
// Roster objects are immutable, but all players on a roster
// have mutable status, which can affect the values returned by
// the readyCount() and readyRoster() methods.
//
// If r1 and r2 are rosters, then r1.equals(r2) if and only if
// every player on roster r1 is also on roster r2, and
// every player on roster r2 is also on roster r1.
//
// If r is a roster, then r.hashCode() always returns the same
// value, even if r has some players whose status changes.
//
// If r1 and r2 are rosters of different sizes, then
// r1.toString() is not the same string as r2.toString().
//
// Rosters.empty() is a static factory method that returns an
// empty roster.

public class Rosters implements Roster{
	private Player[] roster;
	
	private Rosters(Player[] players) {
		this.roster=players;
	}
	
	// Returns an empty roster
	public static Roster empty() {
		Player[] emptyRoster=new Player[0];
		return new Rosters(emptyRoster);
	}

	// Returns a roster consisting of the given player together
    // with all players on this roster.
    // Example:
    //     r.with(p).with(p)  =>  r.with(p)
	@Override
	public Roster with(Player p) {
		// TODO Auto-generated method stub
		if(this.has(p))
			return this;
		else { 
			Player[] r=new Player[this.size()+1];
			for(int i=0;i<this.size();i++) {
				r[i]=this.roster[i];
			}
			r[this.size()]=p;
			return new Rosters(r);
		}
			
	}

	// Returns a roster consisting of all players on this roster
    // except for the given player.
    // Examples:
    //     Rosters.empty().without(p)  =>  Rosters.empty()
    //     r.without(p).without(p)     =>  r.without(p)
	@Override
	public Roster without(Player p) {
		// TODO Auto-generated method stub
		if(this.has(p)) {
			Player[] r=new Player[this.size()-1];
			List<Player> lst=new ArrayList();
			for(int i=0;i<this.size();i++) {
				if(this.roster[i]!=p)
					lst.add(roster[i]);
			}
			for(int i=0;i<this.size()-1;i++) {
				r[i]=lst.get(i);
			}
			return new Rosters(r);
		}
		else {
			return this;
		}
	}

	// Returns true iff the given player is on this roster.
    // Examples:
    //
    //     Rosters.empty().has(p)  =>  false
    //
    // If r is any roster, then
    //
    //     r.with(p).has(p)     =>  true
    //     r.without(p).has(p)  =>  false
	@Override
	public boolean has(Player p) {
		// TODO Auto-generated method stub
		for(int i=0;i<this.roster.length;i++) {
			if(roster[i]==p)
				return true;
		}
		return false;
	}

	// Returns the number of players on this roster.
    // Examples:
    //
    //     Rosters.empty().size()  =>  0
    //
    // If r is a roster with r.size() == n, and r.has(p) is false, then
    //
    //     r.without(p).size()          =>  n
    //     r.with(p).size()             =>  n+1
    //     r.with(p).with(p).size()     =>  n+1
    //     r.with(p).without(p).size()  =>  n
	@Override
	public int size() {
		// TODO Auto-generated method stub
		return this.roster.length;
	}

	// Returns the number of players on this roster whose current
    // status indicates they are available.
	// Example:
	// Player p1=Players.make("David");
    // Player p2=Players.make("Messi");
    // Player p3=Players.make("Jackie");
    // Roster r1=Rosters.empty().with(p1).with(p2).with(p3);
	// p1.changeContractStatus(false);
	// r1.readyCount()=>2
	@Override
	public int readyCount() {
		// TODO Auto-generated method stub
		int count=0;
		for(int i=0;i<this.size();i++) {
			if(this.roster[i].available())
				count++;
		}
		return count;
	}

	// Returns a roster consisting of all players on this roster
    // whose current status indicates they are available.
	// Example:
	// Player p1=Players.make("David");
    // Player p2=Players.make("Messi");
    // Player p3=Players.make("Jackie");
    // Roster r1=Rosters.empty().with(p1).with(p2).with(p3);
	// p1.changeContractStatus(false);
	// r1.readyRoster()=>Rosters.empty().with(p2).with(p3);
	@Override
	public Roster readyRoster() {
		// TODO Auto-generated method stub
		List<Player> lst=new ArrayList();
		for(int i=0;i<this.size();i++) {
			if(this.roster[i].available())
				lst.add(roster[i]);
		}
		Player[] r=new Player[lst.size()];
		for(int i=0;i<lst.size();i++) {
			r[i]=lst.get(i);
		}
		return new Rosters(r);
	}

	// Returns an iterator that generates each player on this
    // roster exactly once, in alphabetical order by name.
	@Override
	public Iterator<Player> iterator() {
		// TODO Auto-generated method stub        
		return new playerIterator();
	}
	Stream<Player> stream (){
		List<Player> lst=generateList();
		return lst.stream();
	}
	
	// Returns -1 if p1's name lexicographically precedes p2's name 
	// Returns 1 if p2's name lexicographically precedes p1's name 
	// Returns 1 if p1's name is lexicographically same as p2's name 
	int compareStr(Player p1, Player p2) {
    	return p1.name().compareTo(p2.name());
    }
	
	// Returns true if and only if every player on roster r1 is also
	// on roster r2, and every player on roster r2 s also on roster r1
	// Examples:
	// Player p1=Players.make("David");
    // Player p2=Players.make("Messi");
    // Player p3=Players.make("Jackie");
    // Roster r1=Rosters.empty().with(p1).with(p2).with(p3);
	// Roster r2=Rosters.empty().with(p1).with(p2).with(p3);
	// r1.equals(r2)=>true
	// Roster r3=r1.without(p1);
	// r1.equals(r3)=>false
	
	// Returns a list of player which has the same players
	// as the current roster
	private List<Player> generateList(){
		List<Player> lst=new ArrayList();
		for(int i=0;i<this.size();i++) {
			lst.add(this.roster[i]);
		}
		return lst;
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + Arrays.hashCode(roster);
		return result;
	}

	@Override
	public boolean equals(Object c) {
		// TODO Auto-generated method stub
		if(c instanceof Roster) {
			Roster r=(Roster)c;
			List<Player> lst=generateList();
			if(r.size()==this.size()) {
				for(int i=0;i<this.size();i++) {
					if(!r.has(this.roster[i]))
						return false;
				}
				return true;
			}
		}
		return false;
	}

	// Returns the size() of the current roster
	@Override
	public String toString() {
		// TODO Auto-generated method stub		
		return String.valueOf(this.size());
	}

	// The inner class implementing Iterator<Player>
	private class playerIterator implements Iterator<Player>{
		private Player[] orderRoster; // The alphabetically ordered roster
		private int index=0;// pointer for next()
		
		// Initiate orderRoster
		public playerIterator() {
			List<Player> lst=new ArrayList();
			for(int i=0;i<size();i++) {
				lst.add(roster[i]);
			}		
			Comparator<Player> alpha = (c1, c2) -> compareStr(c1,c2);
			lst.sort(alpha);
			Player[] ps=new Player[lst.size()];
			for(int i=0;i<lst.size();i++) {
				ps[i]=lst.get(i);
			}
			orderRoster=ps;
		}

		@Override
		public boolean hasNext() {
			// TODO Auto-generated method stub
			return index<orderRoster.length;
		}

		@Override
		public Player next() {
			// TODO Auto-generated method stub
			return orderRoster[index++];
		}
		
//		public void remove() {
//            throw new UnsupportedOperationException();
//        }
	}
}
