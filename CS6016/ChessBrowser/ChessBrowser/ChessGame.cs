namespace ChessBrowser;
using ChessBrowser; 

public class Player
{
    public string Name;
    public int Elo;
}

public class WhitePlayer : Player;

public class BlackPlayer : Player;

public class Event
{
    public string EventName;
    public string Site;
    public DateTime EventDate;
}

public class ChessGame
{
    public string Round;
    
    public string Result;

    public string Moves;
    
    public BlackPlayer BlackPlayer = new(); // Initialize Black Player

    public WhitePlayer WhitePlayer = new(); // Initialize White Player

    public Event Event = new(); // Ensure Event is initialized
    
    public void DisplayGameInfo()
    {
        System.Diagnostics.Debug.WriteLine($"Round: {Round}, Result: {Result}, Event: {Event.EventName}, Event Data: {Event.EventDate}");
        System.Diagnostics.Debug.WriteLine($"Players: White - {WhitePlayer.Name} vs Black - {BlackPlayer.Name}");
        System.Diagnostics.Debug.WriteLine($"Moves: {Moves}");
    }
    
}

