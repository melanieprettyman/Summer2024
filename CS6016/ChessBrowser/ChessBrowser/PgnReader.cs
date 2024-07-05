using System;
using Microsoft.Maui.Controls;
using static System.Net.Mime.MediaTypeNames;

namespace ChessBrowser
{
	public static class PgnReader
	{
        public static List<ChessGame> Games;

        public static void ReadPgnFile (string path)
        {
            Games = new List<ChessGame>();

            ChessGame currentGame = null;
            
            string[] pngFile = File.ReadAllLines(path);
            Console.WriteLine("--------In the parser-----");

            foreach (string line in pngFile)
            {
                if (line.StartsWith("[Event "))
                {
                    currentGame = new ChessGame();
                    string eventName = getStringBetweenQuotes(line);
                    currentGame.Event.EventName = eventName;
                    Games.Add(currentGame);
                }
                if (line.StartsWith("[Site "))
                {
                    string siteName = getStringBetweenQuotes(line);
                    currentGame.Event.Site = siteName;
                }
                if (line.StartsWith("[Round "))
                {
                    string round = getStringBetweenQuotes(line);
                    currentGame.Round = round;
                }
                if (line.StartsWith("[White "))
                {
                    string whitePlayerName = getStringBetweenQuotes(line);
                    currentGame.WhitePlayer.Name = whitePlayerName;

                }
                if (line.StartsWith("[Black "))
                {
                    string blackPlayerName = getStringBetweenQuotes(line);
                    currentGame.BlackPlayer.Name = blackPlayerName;

                }
                if (line.StartsWith("[Result "))
                {
                    string result = getStringBetweenQuotes(line);
                    if (result == "1-0")
                    {
                        currentGame.Result = "W";
                    }
                    else if (result == "0-1")
                    {
                        currentGame.Result = "B";
                    }
                    else if (result == "1/2-1/2")
                    {
                        currentGame.Result = "D";
                    }
                    else
                    {
                        currentGame.Result = "Error"; 
                    }
                }
                if (line.StartsWith("[WhiteElo "))
                {
                    string whiteElo = getStringBetweenQuotes(line);
                    int parsedElo;

                    if (int.TryParse(whiteElo, out parsedElo))
                    {
                        currentGame.WhitePlayer.Elo = parsedElo;
                    }
                    else
                    {
                        // Handle the case where parsing fails
                        Console.WriteLine("Invalid Elo rating: " + whiteElo);
                    }

                }
                if (line.StartsWith("[BlackElo "))
                {
                    string blackElo = getStringBetweenQuotes(line);
                    int parsedElo;

                    if (int.TryParse(blackElo, out parsedElo))
                    {
                        currentGame.BlackPlayer.Elo = parsedElo;
                    }
                    else
                    {
                        // Handle the case where parsing fails
                        Console.WriteLine("Invalid Elo rating: " + blackElo);
                    }
                }
                if (line.StartsWith("[EventDate "))
                {
                    string eventDate = getStringBetweenQuotes(line);
                    DateTime parsedDate;

                    if (DateTime.TryParse(eventDate, out parsedDate))
                    {
                        currentGame.Event.EventDate = parsedDate;
                    }
                    else
                    {
                        // Handle the case where parsing fails
                        Console.WriteLine("Invalid date format: " + eventDate);
                    }
                }
                if (!line.StartsWith("["))
                {
                    currentGame.Moves += line;
                }
            }

        }

        public static string getStringBetweenQuotes (string text)
        {
            int firstColon = text.IndexOf('"');
            int secondColon = text.LastIndexOf('"');
            string textBetween = text.Substring(firstColon + 1, secondColon - firstColon - 1);
            return textBetween;
        }



    }
}
