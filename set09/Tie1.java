// Constructor template for Tie1:
//     new Tie1 (Competitor c1, Competitor c2)
// Interpretation:
//     c1 and c2 have engaged in a contest that ended in a tie

public class Tie1 implements Outcome {

    // You should define your fields here.
    Competitor comp1; //a competitor in the tie outcome
    Competitor comp2; //another competitor in the outcome
    Tie1 (Competitor c1, Competitor c2) {

        // Your code goes here.
        comp1=c1;
        comp2=c2;
    }

    // RETURNS: true iff this outcome represents a tie

    public boolean isTie () {

        // Your code goes here.
        return true;
    }

    // RETURNS: one of the competitors

    public Competitor first () {

        // Your code goes here.
        return comp1;
    }

    // RETURNS: the other competitor

    public Competitor second () {

        // Your code goes here.
        return comp2;
    }

    // GIVEN: no arguments
    // WHERE: this.isTie() is false
    // RETURNS: the winner of this outcome

    public Competitor winner () {

        // Your code goes here.
        return null;
    }

    // GIVEN: no arguments
    // WHERE: this.isTie() is false
    // RETURNS: the loser of this outcome

    public Competitor loser () {

        // Your code goes here.
        return null;
    }
}
