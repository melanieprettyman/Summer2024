using Microsoft.Maui.Controls;
using MySqlConnector;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ChessBrowser;
using UIKit;

namespace ChessBrowser
{
  internal class Queries
  {

    /// <summary>
    /// This function runs when the upload button is pressed.
    /// Given a filename, parses the PGN file, and uploads
    /// each chess game to the user's database.
    /// </summary>
    /// <param name="PGNfilename">The path to the PGN file</param>
    internal static async Task InsertGameData( string PGNfilename, MainPage mainPage )
    {
      // This will build a connection string to your user's database on atr,
      // assuimg you've typed a user and password in the GUI
      string connection = mainPage.GetConnectionString();

      // TODO:
      //       Load and parse the PGN file
      //       We recommend creating separate libraries to represent chess data and load the file
      PgnReader.ReadPgnFile(PGNfilename);


      // TODO:
      //       Use this to tell the GUI's progress bar how many total work steps there are
      //       For example, one iteration of your main upload loop could be one work step
      mainPage.SetNumWorkItems(PgnReader.Games.Count);


      using ( MySqlConnection conn = new MySqlConnection( connection ) )
      {
        try
        {
          // Open a connection
          conn.Open();
          System.Diagnostics.Debug.WriteLine("CONNECTION OPEN");

          // TODO:
          //       iterate through your data and generate appropriate insert commands
          foreach (ChessGame game in PgnReader.Games)
          {
            //INSERT EVENT 
            string eventInsertQuery = "INSERT IGNORE INTO Events (Name, Site, Date) Values (@Name, @Site, @Date)";
            await using (MySqlCommand command = new MySqlCommand(eventInsertQuery, conn))
            {
              command.Parameters.AddWithValue("@Name", game.Event.EventName);
              command.Parameters.AddWithValue("@Site", game.Event.Site);
              command.Parameters.AddWithValue("@Date", game.Event.EventDate);
              command.ExecuteNonQuery();
            }
            
            //GET EVENT-ID OF EVENT INSERTED ABOVE
            string getEid = "SELECT eID from Events where Name = @Name and Site = @Site and Date = @Date";
            int eID; //init event-id
            using (MySqlCommand command = new MySqlCommand(getEid, conn))
            {
              command.Parameters.AddWithValue("@Name", game.Event.EventName);
              command.Parameters.AddWithValue("@Site", game.Event.Site);
              command.Parameters.AddWithValue("@Date", game.Event.EventDate);
              eID = Convert.ToInt32(command.ExecuteScalar());
            }
            
            //INSERT WHITE-PLAYER
            string whitePlayersInsertQuery = "INSERT INTO Players (Name, Elo) Values (@Name, @Elo) ON DUPLICATE KEY UPDATE Elo = GREATEST(Elo, @Elo)";
            using (MySqlCommand command = new MySqlCommand(whitePlayersInsertQuery, conn))
            {
              command.Parameters.AddWithValue("@Name", game.WhitePlayer.Name);
              command.Parameters.AddWithValue("@Elo", game.WhitePlayer.Elo);
              command.ExecuteNonQuery();
            }
            
            //GET WHITE-PLAYER PID
            string getWhitePid = "SELECT PID from Players where Name = @WhitePlayer";
            int wID; 
            using (MySqlCommand command = new MySqlCommand(getWhitePid, conn))
            {
              command.Parameters.AddWithValue("@WhitePlayer", game.WhitePlayer.Name);
              wID = Convert.ToInt32(command.ExecuteScalar());

            }
            
            //INSERT BLACK-PLAYER
            string blackPlayersInsertQuery = "INSERT INTO Players (Name, Elo) Values (@Name, @Elo) ON DUPLICATE KEY UPDATE Elo = GREATEST(Elo, @Elo)";
            using (MySqlCommand command = new MySqlCommand(blackPlayersInsertQuery, conn))
            {
              command.Parameters.AddWithValue("@Name", game.BlackPlayer.Name);
              command.Parameters.AddWithValue("@Elo", game.BlackPlayer.Elo);
              command.ExecuteNonQuery();
            }
            
            //GET BLACK-PLAYER PID
            string getBlackPid = "SELECT pID from Players where Name = @BlackPlayer";
            int bID;
            using (MySqlCommand command = new MySqlCommand(getBlackPid, conn))
            {
              command.Parameters.AddWithValue("@BlackPlayer", game.BlackPlayer.Name);
              bID = Convert.ToInt32(command.ExecuteScalar());

            }
            
            //INSERT GAME 
            string insertGamesQuery = "INSERT IGNORE INTO Games (Round, Result, Moves, BlackPlayer, WhitePlayer, eID) VALUES (@Round, @Result, @Moves, @BlackPlayer, @WhitePlayer, @eID)";
            using (MySqlCommand command = new MySqlCommand(insertGamesQuery, conn))
            { 
              command.Parameters.AddWithValue("@Round", game.Round);
              command.Parameters.AddWithValue("@Result", game.Result);
              command.Parameters.AddWithValue("@Moves", game.Moves);
              command.Parameters.AddWithValue("@BlackPlayer", bID);
              command.Parameters.AddWithValue("@WhitePlayer", wID);
              command.Parameters.AddWithValue("@eID", eID);
              command.ExecuteNonQuery();
            }
            System.Diagnostics.Debug.WriteLine("GAME INSERTED");

            await mainPage.NotifyWorkItemCompleted();//tell the GUI that one work step has completed (1 game in games)
          }

        }
        catch ( Exception e )
        {
          System.Diagnostics.Debug.WriteLine( e.Message );
        }
      }

    }


    /// <summary>
    /// Queries the database for games that match all the given filters.
    /// The filters are taken from the various controls in the GUI.
    /// </summary>
    /// <param name="white">The white player, or null if none</param>
    /// <param name="black">The black player, or null if none</param>
    /// <param name="opening">The first move, e.g. "1.e4", or null if none</param>
    /// <param name="winner">The winner as "W", "B", "D", or null if none</param>
    /// <param name="useDate">True if the filter includes a date range, False otherwise</param>
    /// <param name="start">The start of the date range</param>
    /// <param name="end">The end of the date range</param>
    /// <param name="showMoves">True if the returned data should include the PGN moves</param>
    /// <returns>A string separated by newlines containing the filtered games</returns>
    internal static string PerformQuery( string white, string black, string opening,
      string winner, bool useDate, DateTime start, DateTime end, bool showMoves,
      MainPage mainPage )
    {
      // This will build a connection string to your user's database on atr,
      // assuimg you've typed a user and password in the GUI
      string connection = mainPage.GetConnectionString();

      // Build up this string containing the results from your query
      string parsedResult = "";

      // Use this to count the number of rows returned by your query
      // (see below return statement)
      int numRows = 0;

      using ( MySqlConnection conn = new MySqlConnection( connection ) )
      {
        try
        {
         // Open a connection
            conn.Open();
            MySqlCommand cmd = conn.CreateCommand();
            string query = "select E.Name, E.Site, E.Date, WP.Name, WP.Elo, BP.Name, BP.Elo, G.Result, G.Moves from Events E natural join Games G join Players WP on G.WhitePlayer = WP.pID join Players BP on G.BlackPlayer = BP.pID";

            cmd.Parameters.AddWithValue("@WhitePlayer", white);
            cmd.Parameters.AddWithValue("@BlackPlayer", black);
            cmd.Parameters.AddWithValue("@opening", opening + "%");
            cmd.Parameters.AddWithValue("@winner", winner);
            cmd.Parameters.AddWithValue("@start", start);
            cmd.Parameters.AddWithValue("@end", end);

            if (white != null) {
              query += " WHERE WP.Name = @WhitePlayer";
            }

            if (black != null)
            {
              query += " WHERE BP.Name = @BlackPlayer";
            }

            if (opening != null)
            {
              query += " AND G.Moves like @opening";
            }
            if ( winner != null)
            {
              query += " AND G.Result = @winner";
          
            }
            if ( useDate )
            {
              query += " AND E.Date BETWEEN @start AND @end";
            }

            query += ";";

            cmd.CommandText = query;


            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    parsedResult += "Event: " + reader[0] + "\n";
                    parsedResult += "Site: " + reader[1] + "\n";
                    parsedResult += "Date: " + reader[2] + "\n";
                    parsedResult += "White: " + reader[3] + " (" + reader[4] + ")\n";
                    parsedResult += "Black: " + reader[5] + " (" + reader[6] + ")\n";
                    parsedResult += "Result: " + reader[7] + "\n";
                    if (showMoves)
                    {
                        parsedResult += "Moves: " + reader[8] + "\n";
                    }
                    parsedResult += "\n";
                    numRows++;
                    
                }
            }
            
        }
        catch ( Exception e )
        {
          System.Diagnostics.Debug.WriteLine( e.Message );
        }
      }
      
      return numRows + " results\n" + parsedResult;

    }

  }
}
