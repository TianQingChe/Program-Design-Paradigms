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
public class NewPlayer implements Player{
	private String name;
	private boolean underContract;
	private boolean isInjured;
	private boolean isSuspended;
	
	public NewPlayer(String n) {
		this.name=n;
		this.underContract=true;
		this.isInjured=false;
		this.isSuspended=false;
	}

	// Returns the name of this player.
    // Example:
    //     Players.make("Gordon Wayhard").name()  =>  "Gordon Wayhard"
	@Override
	public String name() {
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
		return this.underContract() && !this.isInjured() && !this.isSuspended();
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
		return this.underContract;
	}

	// Returns true iff this player is injured.
	@Override
	public boolean isInjured() {
		return this.isInjured;
	}

	// Returns true iff this player is suspended.
	@Override
	public boolean isSuspended() {
		return this.isSuspended;
	}

	// Changes the underContract() status of this player
    // to the specified boolean.
	@Override
	public void changeContractStatus(boolean newStatus) {
		this.underContract=newStatus;
	}

	// Changes the isInjured() status of this player
    // to the specified boolean.
	@Override
	public void changeInjuryStatus(boolean newStatus) {
		this.isInjured=newStatus;
	}

	// Changes the isSuspended() status of this player
    // to the specified boolean.
	@Override
	public void changeSuspendedStatus(boolean newStatus) {
		this.isSuspended=newStatus;
	}
	
	// Returns the name of this player
	@Override
	public String toString() {
		return this.name;
	}
}
