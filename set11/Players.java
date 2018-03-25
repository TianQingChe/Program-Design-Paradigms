
public class Players{
	// Returns a player with the given name who is (initially) available.
	// Example:
    //  Player gw = Players.make ("Gordon Wayhard");
    //  System.out.println (gw.available());  // prints true
    //  System.out.println (gw.underContract());  // prints true
    //  System.out.println (gw.isInjured());  // prints false
    //  System.out.println (gw.isSuspended());  // prints false
	public static Player make(String n) {
		return new NewPlayer(n);
	}
}
