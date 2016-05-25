import UIKit
import Foundation


var leagues = [String]()
var matchdays = [Int]()
var games = [Int]()
var current_Matchday = [Int]()


extension UIView
{
    func centerHorizontallyInSuperview()
    {
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self,
                                                       attribute: NSLayoutAttribute.CenterX,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: self.superview,
                                                       attribute: NSLayoutAttribute.CenterX,
                                                       multiplier:1,
                                                       constant: 0)
        
        // Add this constraint to the superview
        self.superview?.addConstraint(c)
    }
}
//opening page view conntoller
class openingViewController : UIViewController {
    
    
    
    // Views that need to be accessible to all methods
    let jsonResult = UILabel()
    
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        
        // Print the provided data
        //        print("")
        //        print("====== the data provided to parseMyJSON is as follows ======")
        //        print(theData)
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            // Source JSON is here:
            // http://api.football-data.org/v1/soccerseasons/
            //
            let json = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            
            for eachFootballData in json {
                //
                //                // Try to cast the current anyObject in the array of AnyObjects to a dictionary
                if let footballData = eachFootballData as? [String : AnyObject] {
                    //
                    //                    // A successful cast...
                    //                    //
                    //                    // Now try casting key values to see if this cooling centre is closest
                    //                    // to the current location
                    guard let currentMatchday : Int = footballData["currentMatchday"] as? Int,
                        let numberOfGames : Int = footballData["numberOfGames"]  as? Int,
                        let leagueName : String = footballData["caption"] as? String,
                        let numberOfMatchdays : Int = footballData["numberOfMatchdays"] as? Int
                        
                        else {
                            print("Problem getting the football data")
                            return
                    }
                    
                    leagues.append(leagueName)
                    matchdays.append(numberOfMatchdays)
                    games.append(numberOfGames)
                    current_Matchday.append(currentMatchday)
                    
                }
            }

            
            
            
            
            // Now we can update the UI
            // (must be done asynchronously)
            dispatch_async(dispatch_get_main_queue()) {
                self.jsonResult.text = "parsed JSON should go here"
            }
            
        } catch let error as NSError {
            print ("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    //------------------------------------------------------------------------------------------------------------
    
    // Set up and begin an asynchronous request for JSON data
    func getMyJSON() {
        
        // Define a completion handler
        // The completion handler is what gets called when this **asynchronous** network request is completed.
        // This is where we'd process the JSON retrieved
        let myCompletionHandler : (NSData?, NSURLResponse?, NSError?) -> Void = {
            
            (data, response, error) in
            
            // This is the code run when the network request completes
            // When the request completes:
            //
            // data - contains the data from the request
            // response - contains the HTTP response code(s)
            // error - contains any error messages, if applicable
            
            // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
            if let r = response as? NSHTTPURLResponse {
                
                // If the request was successful, parse the given data
                if r.statusCode == 200 {
                    
                    if let d = data {
                        
                        // Parse the retrieved data
                        self.parseMyJSON(d)
                        
                    }
                    
                }
                
            }
            
        }
        
        
        // Define a URL to retrieve a JSON file from
        let address : String = "http://api.football-data.org/v1/soccerseasons/"
        
        // Try to make a URL request object
        if let url = NSURL(string: address) {
            
            // We have an valid URL to work with
            // print(url)
            
            // Now we create a URL request object
            let urlRequest = NSURLRequest(URL: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTaskWithRequest(urlRequest, completionHandler: myCompletionHandler)
            
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        
    }

    //gets JSON before page loads
    override func viewDidLoad() {
        getMyJSON()
    }
}

//second page view controller with table
class scoresListViewController : UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    //creating variables to send values of dictionaries to next page
    var todayMatchday = "Today's Matchday"
    var gamesInASeason = "Games in a season"
    var matchdaysInASeason = "Matchdays in a season"
    
    //creating table in code
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {

        self.tableView.dataSource = self
        self.tableView.delegate = self

        super.viewDidLoad()
    }
    
    //home many rows will the table have
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return leagues.count
        
    }
    
    //what will be in each of the cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        

        cell.textLabel!.text = leagues[indexPath.row]
       // cell.backgroundColor = UIColor.lightGrayColor()
        
        
        return cell
    }
    
    //what happens when a row is pressed
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //sets variables to index at row pressed
        self.todayMatchday = "\(current_Matchday[indexPath.row])"
        self.gamesInASeason = "\(games[indexPath.row])"
        self.matchdaysInASeason = "\(matchdays[indexPath.row])"
        
        //runs segue
        self.performSegueWithIdentifier("mainToOtherSegue", sender: self)
    }
    
    //sending the contents of my created variables at the right index to the next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let currentMatchdaySending = segue.destinationViewController as! leagueStatsViewController
        currentMatchdaySending.todayMatchday = self.todayMatchday
        
        let gamesInASeasonSending = segue.destinationViewController as! leagueStatsViewController
        gamesInASeasonSending.gamesInASeason = self.gamesInASeason
        
        let matchdaysInASeasonSending = segue.destinationViewController as! leagueStatsViewController
        matchdaysInASeasonSending.matchdaysInASeason = self.matchdaysInASeason
        


    }
    
}

//score summary view controller
class leagueStatsViewController : UIViewController {
    
    //variables which recieved information about what to display from previous view controller
    var todayMatchday = "Today's Matchday"
    var gamesInASeason = "Games in a season"
    var matchdaysInASeason = "Matchdays in a season"


    //create all of the used labels in code
   
    @IBOutlet weak var currentMatchday1: UILabel!
    @IBOutlet weak var gamesInASeason1: UILabel!
    @IBOutlet weak var matchdaysInASeason1: UILabel!
    
    override func viewDidLoad() {
        
        //tells swift what to display in each label
        self.currentMatchday1.text = "It is the \(todayMatchday)th matchday"
        self.currentMatchday1.numberOfLines = 0;
        
        self.gamesInASeason1.text = "There are \(gamesInASeason) games in a season"
        self.gamesInASeason1.numberOfLines = 0;
        
        self.matchdaysInASeason1.text = "There are \(matchdaysInASeason) matchdays in a season"
        self.matchdaysInASeason1.numberOfLines = 0;
        
        currentMatchday1.textAlignment = NSTextAlignment.Center
        gamesInASeason1.textAlignment = NSTextAlignment.Center
        matchdaysInASeason1.textAlignment = NSTextAlignment.Center
        
        
    }
}