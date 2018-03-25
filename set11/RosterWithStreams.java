import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;


public class RosterWithStreams implements RosterWithStream{

    private List<Player> roster;
	
	private RosterWithStreams(List<Player> players) {
		this.roster=players;
	}
	
	// Returns an empty roster
	public static RosterWithStream empty() {
		return new RosterWithStreams(new ArrayList<Player>());
	}

	// Returns a roster consisting of the given player together
    // with all players on this roster.
    // Example:
    //     r.with(p).with(p)  =>  r.with(p)
	@Override
	public RosterWithStream with(Player p) {
		// TODO Auto-generated method stub
		if(this.has(p))
			return this;
		else {
			List<Player> r=new ArrayList();
			r.addAll(this.roster);
			r.add(p);
			return new RosterWithStreams(r);
		}	
	}

	// Returns a roster consisting of all players on this roster
    // except for the given player.
    // Examples:
    //     Rosters.empty().without(p)  =>  Rosters.empty()
    //     r.without(p).without(p)     =>  r.without(p)
	@Override
	public RosterWithStream without(Player p) {
		// TODO Auto-generated method stub
		List<Player> r=new ArrayList();
		r.addAll(this.roster);
		r.remove(p);
		return new RosterWithStreams(r);
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
		return this.roster.contains(p);
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
		return this.roster.size();
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
		return this.readyRoster().size();
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
	public RosterWithStream readyRoster() {
		// TODO Auto-generated method stub
		return new RosterWithStreams(this.stream().filter(p->p.available()).collect(Collectors.toList()));
	}

	// Returns an iterator that generates each player on this
    // roster exactly once, in alphabetical order by name.
	@Override
	public Iterator<Player> iterator() {
		// TODO Auto-generated method stub  	
		List<Player> sortedRoster=new ArrayList();
		sortedRoster.addAll(this.roster);
		sortedRoster.sort((c1, c2) -> compareStr(c1,c2));
		return sortedRoster.iterator();
	}
	
	// Returns a sequential Stream with this RosterWithStream
    // as its source.
    // The result of this method generates each player on this
    // roster exactly once, in alphabetical order by name.
    // Examples:
    //
    //     RosterWithStreams.empty().stream().count()  =>  0
    //
    //     RosterWithStreams.empty().stream().findFirst().isPresent()
    //         =>  false
    //
    //     RosterWithStreams.empty().with(p).stream().findFirst().get()
    //         =>  p
    //
    //     this.stream().distinct()  =>  true
    //
    //     this.stream().filter((Player p) -> p.available()).count()
    //         =>  this.readyCount()
	public Stream<Player> stream (){
		return this.roster.stream();
	}
	
	// Returns -1 if p1's name lexicographically precedes p2's name 
	// Returns 1 if p2's name lexicographically precedes p1's name 
	// Returns 1 if p1's name is lexicographically same as p2's name 
	int compareStr(Player p1, Player p2) {
    	return p1.name().compareTo(p2.name());
    }

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + roster.hashCode();
		return result;
	}
	public String toString() {
		return String.valueOf(this.size());
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
	public boolean equals(Object c) {
	// TODO Auto-generated method stub
	if (this == c)
		return true;
	if (c == null)
		return false;
	if(c instanceof RosterWithStream) {
		RosterWithStream r=(RosterWithStream)c;
		if(r.size()==this.size()) {
			Iterator<Player> thisI=this.iterator();
			Iterator<Player> otherI=r.iterator();
			while(thisI.hasNext()) {
				if(!thisI.next().equals(otherI.next()))
					return false;
			}
			return true;
		}
	}
	return false;
}
	
}
