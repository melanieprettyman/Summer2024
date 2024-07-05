using LibraryWebServer.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Runtime.CompilerServices;

[assembly: InternalsVisibleTo( "TestProject1" )]
namespace LibraryWebServer.Controllers
{
    public class HomeController : Controller
    {

        // WARNING:
        // This very simple web server is designed to be as tiny and simple as possible
        // This is NOT the way to save user data.
        // This will only allow one user of the web server at a time (aside from major security concerns).
        private static string user = "";
        private static int card = -1;

        private readonly LibraryContext db;
        public HomeController(LibraryContext _db)
        {
            db = _db;
        }

        /// <summary>
        /// Given a Patron name and CardNum, verify that they exist and match in the database.
        /// If the login is successful, sets the global variables "user" and "card"
        /// </summary>
        /// <param name="name">The Patron's name</param>
        /// <param name="cardnum">The Patron's card number</param>
        /// <returns>A JSON object with a single field: "success" with a boolean value:
        /// true if the login is accepted, false otherwise.
        /// </returns>
        [HttpPost]
        public IActionResult CheckLogin( string name, int cardnum )
        {
            // TODO: Fill in. Determine if login is successful or not.
            bool loginSuccessful = false;

            // LINQ query to check if the provided name and card number exist in the Patrons table
            var query = from Patrons in db.Patrons where Patrons.Name == name && Patrons.CardNum == cardnum select new {userName = Patrons.Name, userCard = Patrons.CardNum};

            // If exactly one matching record is found, the login is successful
            if(query.Count() == 1)
            {
                loginSuccessful = true;
            }
            
            if ( !loginSuccessful )
            {
                return Json( new { success = false } );
            }
            else
            {
                user = name;
                card = cardnum;
                return Json( new { success = true } );
            }
        }


        /// <summary>
        /// Logs a user out. This is implemented for you.
        /// </summary>
        /// <returns>Success</returns>
        [HttpPost]
        public ActionResult LogOut()
        {
            user = "";
            card = -1;
            return Json( new { success = true } );
        }

        /// <summary>
        /// Returns a JSON array representing all known books.
        /// Each book should contain the following fields:
        /// {"isbn" (string), "title" (string), "author" (string), "serial" (uint?), "name" (string)}
        /// Every object in the list should have isbn, title, and author.
        /// Books that are not in the Library's inventory (such as Dune) should have a null serial.
        /// The "name" field is the name of the Patron who currently has the book checked out (if any)
        /// Books that are not checked out should have an empty string "" for name.
        /// </summary>
        /// <returns>The JSON representation of the books</returns>
        [HttpPost]
        public ActionResult AllTitles()
        {

            var query = from T in db.Titles
                        // Group join Titles and Inventory on ISBN
                        join I in db.Inventory
                        on T.Isbn equals I.Isbn
                        into titles_Join_Inventory

                        // Iterate through the collection titles_Join_Inventory, providing a default value (null) if empty
                        from join_1 in titles_Join_Inventory.DefaultIfEmpty()
                        // Left join with CheckedOut on Serial number
                        join c in db.CheckedOut
                        on join_1.Serial equals c.Serial
                        into join_1_Join_CheckedOut

                        // Left join with Patrons on CardNum
                        from join_2 in join_1_Join_CheckedOut.DefaultIfEmpty()
                        join p in db.Patrons
                        on join_2.CardNum equals p.CardNum
                        into join_2_Patrons

                        from j in join_2_Patrons.DefaultIfEmpty()
                        // Select the desired fields, handling possible null values
                        select new
                        {
                            isbn = T.Isbn,
                            title = T.Title,
                            author = T.Author,
                            serial = join_1 == null ? null : (uint?)join_1.Serial, //cast j1.Serial as null so both obj can be compared
                            name = j == null ? "" : j.Name

                        };

            return Json( query.ToArray() );
        }

        /// <summary>
        /// Returns a JSON array representing all books checked out by the logged in user 
        /// The logged in user is tracked by the global variable "card".
        /// Every object in the array should contain the following fields:
        /// {"title" (string), "author" (string), "serial" (uint) (note this is not a nullable uint) }
        /// Every object in the list should have a valid (non-null) value for each field.
        /// </summary>
        /// <returns>The JSON representation of the books</returns>
        [HttpPost]
        public ActionResult ListMyBooks()
        {
            var query = 
                from c in db.CheckedOut
                join i in db.Inventory 
                    on c.Serial equals i.Serial
                    into checkedOut_Join_Inventory

                from join_1 in checkedOut_Join_Inventory
                join t in db.Titles
                    on join_1.Isbn equals t.Isbn
                    into join_1_Join_Titles

                //Create an book obj for each book cardNum has checked out 
                from join_2 in join_1_Join_Titles
                where c.CardNum == card
                select new
                {
                    title = join_2.Title,
                    author = join_2.Author,
                    serial = join_1.Serial,

                };
            
            return Json( query ); //return list of books 
        }


        /// <summary>
        /// Updates the database to represent that
        /// the given book is checked out by the logged in user (global variable "card").
        /// In other words, insert a row into the CheckedOut table.
        /// You can assume that the book is not currently checked out by anyone.
        /// </summary>
        /// <param name="serial">The serial number of the book to check out</param>
        /// <returns>success</returns>
        [HttpPost]
        public ActionResult CheckOutBook( int serial )
        {
            CheckedOut c = new CheckedOut();
            c.Serial = (uint)serial;
            c.CardNum = (uint)card;

            db.CheckedOut.Add(c);
            db.SaveChanges();
            return Json( new { success = true } );
        }

        /// <summary>
        /// Returns a book currently checked out by the logged in user (global variable "card").
        /// In other words, removes a row from the CheckedOut table.
        /// You can assume the book is checked out by the user.
        /// </summary>
        /// <param name="serial">The serial number of the book to return</param>
        /// <returns>Success</returns>
        [HttpPost]
        public ActionResult ReturnBook( int serial )
        {
            CheckedOut c = new CheckedOut();
            c.Serial = (uint)serial;
            c.CardNum = (uint)card;

            db.CheckedOut.Remove(c);
            db.SaveChanges();

            return Json( new { success = true } );
        }


        /*******************************************/
        /****** Do not modify below this line ******/
        /*******************************************/


        public IActionResult Index()
        {
            if ( user == "" && card == -1 )
                return View( "Login" );

            return View();
        }


        /// <summary>
        /// Return the Login page.
        /// </summary>
        /// <returns></returns>
        public IActionResult Login()
        {
            user = "";
            card = -1;

            ViewData["Message"] = "Please login.";

            return View();
        }

        /// <summary>
        /// Return the MyBooks page.
        /// </summary>
        /// <returns></returns>
        public IActionResult MyBooks()
        {
            if ( user == "" && card == -1 )
                return View( "Login" );

            return View();
        }



        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache( Duration = 0, Location = ResponseCacheLocation.None, NoStore = true )]
        public IActionResult Error()
        {
            return View( new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier } );
        }
    }
}