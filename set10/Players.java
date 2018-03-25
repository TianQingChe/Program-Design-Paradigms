// A Player is an object of any class that implements the Player interface.
//
// A Player object represents a member of a team.
// Player objects are mutable because their status can change without
// changing the identity of the Player.
// 
// If p1 and p2 are players, then p1.equals(p2) if and only if
// p1 and p2 are the same object (i.e. (p1 == p2), p1 and p2
// have the same name and status, and changing the status of p1
// necessarily changes the status of p2 in the same way).
//
// If p is a player, then p.hashCode() always returns the same
// value, even after the player's status is changed by calling
// one of the last three methods listed below.
//
// If p1 and p2 are players with distinct names, then
// p1.toString() is not the same string as p2.toString().
//
// Players.make(String name) is a static factory method that returns
// a player with the given name who is (initially) available.

public class Players implements Player{
	private String name;
	private boolean underContract;
	private boolean isInjured;
	private boolean isSuspended;
	
	public Players(String n) {
		this.name=n;
		this.underContract=true;
		this.isInjured=false;
		this.isSuspended=false;
	}
	
	// Returns a player with the given name who is (initially) available.
	// Example:
    //  Player gw = Players.make ("Gordon Wayhard");
    //  System.out.println (gw.available());  // prints true
    //  System.out.println (gw.underContract());  // prints true
    //  System.out.println (gw.isInjured());  // prints false
    //  System.out.println (gw.isSuspended());  // prints false
	public static Player make(String n) {
		return new Players(n);
	}

	// Returns the name of this player.
    // Example:
    //     Players.make("Gordon Wayhard").name()  =>  "Gordon Wayhard"
	@Override
	public String name() {
		// TODO Auto-generated method stub
		return this.name;
	}

	// Returns true iff this player is
    //     under contract, and
    //     not injured, and
    //     not suspended
    // Example:
    //     Player gw = Players.make ("Gordon Wayhard");
    //     System.out.println (gw.available());  // prints true
    //     gw.changeInjuryStatus (true);
    //     System.out.println (gw.available());  // prints false
	@Override
	public boolean available() {
		// TODO Auto-generated method stub
		if(this.underContract && !this.isInjured && !this.isSuspended)
			return true;
		else return false;
	}

	// Returns true iff this player is under contract (employed).
    // Example:
    //     Player ih = Players.make ("Isaac Homas");
    //     System.out.println (ih.underContract());  // prints true
    //     ih.changeContractStatus (false);
    //     System.out.println (ih.underContract());  // prints false
    //     ih.changeContractStatus (true);
    //     System.out.println (ih.underContract());  // prints true
	@Override
	public boolean underContract() {
		// TODO Auto-generated method stub
		return this.underContract;
	}

	// Returns true iff this player is injured.
	@Override
	public boolean isInjured() {
		// TODO Auto-generated method stub
		return this.isInjured;
	}

	// Returns true iff this player is suspended.
	@Override
	public boolean isSuspended() {
		// TODO Auto-generated method stub
		return this.isSuspended;
	}

	// Changes the underContract() status of this player
    // to the specified boolean.
	@Override
	public void changeContractStatus(boolean newStatus) {
		// TODO Auto-generated method stub
		this.underContract=newStatus;
	}

	// Changes the isInjured() status of this player
    // to the specified boolean.
	@Override
	public void changeInjuryStatus(boolean newStatus) {
		// TODO Auto-generated method stub
		this.isInjured=newStatus;
	}

	// Changes the isSuspended() status of this player
    // to the specified boolean.
	@Override
	public void changeSuspendedStatus(boolean newStatus) {
		// TODO Auto-generated method stub
		this.isSuspended=newStatus;
	}
	
	// Returns the name of this player
	@Override
	public String toString() {
		// TODO Auto-generated method stub
		return this.name;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (isInjured ? 1231 : 1237);
		result = prime * result + (isSuspended ? 1231 : 1237);
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + (underContract ? 1231 : 1237);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		else
			return false;
	}

}
