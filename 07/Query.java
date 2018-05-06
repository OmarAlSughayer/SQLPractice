// CSE 344, HW07
// Omar Adel AlSughayer, 1337255
// Section AA

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Properties;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.io.FileInputStream;
import java.util.Map;
import java.util.HashMap;

/**
 * Runs queries against a back-end database
 */
public class Query {

	private String configFilename;
	private Properties configProps = new Properties();

	private String jSQLDriver;
	private String jSQLUrl;
	private String jSQLUser;
	private String jSQLPassword;

	// DB Connection
	private Connection conn;

	// Logged In User
	private String username;
        private Integer cid; // Unique customer ID
    private Map<Integer, int[]> lastSearchFids;

    private static final Integer CAPACITY = 3;
	// Canned queries

       // search (one hop) -- This query ignores the month and year entirely. You can change it to fix the month and year
       // to July 2015 or you can add month and year as extra, optional, arguments
	private static final String SEARCH_ONE_HOP_SQL =
			"SELECT TOP (?) fid, year,month_id,day_of_month,carrier_id,flight_num,origin_city,actual_time "
					+ "FROM Flights "
					+ "WHERE origin_city = ? AND dest_city = ? AND day_of_month = ? "
					+ "ORDER BY actual_time ASC";
	private PreparedStatement searchOneHopStatement;

       // TODO: Add more queries here

	// login -- this query returns the info of a customer with the given name (cid) and password
	private static final String LOGIN_SQL =  
			"SELECT * FROM Customers WHERE login = ? AND pass = ?"; 
	private PreparedStatement loginStatement;

	// List all cities that cannot be reached from Seattle with a direct flight, but
	// can be reached with one city inbetween (i.e. two flights)
	private static final String SEARCH_TWO_HOP_SQL =
			"SELECT TOP (?) "
			+			"f1.fid as fid_f1, f1.origin_city as oc_f1, f1.dest_city as dc_f1, f1.flight_num as nf1, "
			+ 			"f2.fid as fid_f2, f2.origin_city as oc_f2, f2.dest_city as dc_f2, f1.flight_num as nf2, "
			+			"f1.year as yf1, f1.month_id as mf1, f1.day_of_month as df1, "
			+			"f2.year as yf2, f2.month_id as mf2, f2.day_of_month as df2, "
			+ 			"max(f1.actual_time) + max(f2.actual_time) as total "
			+ 		"FROM Flights f1, Flights f2 "
			+ 		"WHERE f1.origin_city = ? AND f2.dest_city = ? AND f1.dest_city = f2.origin_city "
			+ 		"AND f1.day_of_month = ? "
			+ 		"AND f1.actual_time IS NOT NULL AND f2.actual_time IS NOT NULL "
			+ 		"GROUP BY f1.year, f1.month_id, f1.day_of_month, f2.year, f2.month_id, f2.day_of_month, "
			+		"f1.flight_num, f1.fid, f1.origin_city, f1.dest_city, "
			+				"f2.flight_num, f2.fid, f2.origin_city, f2.dest_city "
			+ 		"ORDER BY total;";

	private PreparedStatement searchTwoHopStatement;

	// returns the maximum id in the reservation table
	private static final String MAX_RID_SQL = 
			"SELECT max(rid) FROM Reservations;";
	private PreparedStatement maxRidStatement;

	// returns the number of reservations within a given flight
	private static final String NUM_RESERVATIONS_SQL =
			"SELECT COUNT(*) FROM Reservations WHERE fid = ?;";
	private PreparedStatement numReservationsStatement;

	// adds a reservation to the list
	private static final String ADD_RESERVATION_SQL =
			"INSERT INTO Reservations VALUES (?, ?, ?, ?, ?, ?);";
	private PreparedStatement addReservationStatement;

	// returns all the reservations for a given user
	private static final String CUSTOMER_RESERVATIONS_SQL =
			"SELECT rid, fid FROM Reservations WHERE cid = ?;";
	private PreparedStatement customerResevationsStatement;

	// returns all reservations with a given id by a specific user 
	private static final String SPECIFIC_RESERVATION_SQL =
			"SELECT * FROM Reservations WHERE rid = ? AND cid = ?;";
	private PreparedStatement specificReservationStatement;	

	// cancels a reservation with a specific id 
	private static final String CANCEL_RESERVATION_SQL =
			"DELETE FROM Reservations WHERE rid = ?;";
	private PreparedStatement cancelReservatoinStatement;	
	
	// returns all the reserved flights by a specific user that has the same date as a specific flight
	private static final String CONFLICT_FLIGHTS_SQL =
			"SELECT r.fid "
			+	"FROM Flights f, Reservations r "
			+	"WHERE f.fid = ? AND r.cid = ? "
			+	"AND f.year = r.year AND f.month_id = r.month_id AND f.day_of_month = r.day_of_month;";
	private PreparedStatement conflictFlightsStatement;

	// transactions
	private static final String BEGIN_TRANSACTION_SQL =  
			"SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRANSACTION;"; 
	private PreparedStatement beginTransactionStatement;

	private static final String COMMIT_SQL = "COMMIT TRANSACTION";
	private PreparedStatement commitTransactionStatement;

	private static final String ROLLBACK_SQL = "ROLLBACK TRANSACTION";
	private PreparedStatement rollbackTransactionStatement;


	public Query(String configFilename) {
		this.configFilename = configFilename;
	}

	/**********************************************************/
	/* Connection code to SQL Azure.  */
	public void openConnection() throws Exception {
		configProps.load(new FileInputStream(configFilename));

		jSQLDriver   = configProps.getProperty("flightservice.jdbc_driver");
		jSQLUrl	   = configProps.getProperty("flightservice.url");
		jSQLUser	   = configProps.getProperty("flightservice.sqlazure_username");
		jSQLPassword = configProps.getProperty("flightservice.sqlazure_password");

		/* load jdbc drivers */
		Class.forName(jSQLDriver).newInstance();

		/* open connections to the flights database */
		conn = DriverManager.getConnection(jSQLUrl, // database
				jSQLUser, // user
				jSQLPassword); // password

		conn.setAutoCommit(true); //by default automatically commit after each statement 

		/* You will also want to appropriately set the 
                   transaction's isolation level through:  
		   conn.setTransactionIsolation(...) */
		conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

	}

	public void closeConnection() throws Exception {
		conn.close();
	}

	/**********************************************************/
	/* prepare all the SQL statements in this method.
      "preparing" a statement is almost like compiling it.  Note
       that the parameters (with ?) are still not filled in */

	public void prepareStatements() throws Exception {
		searchOneHopStatement = conn.prepareStatement(SEARCH_ONE_HOP_SQL);
 		beginTransactionStatement = conn.prepareStatement(BEGIN_TRANSACTION_SQL);
		commitTransactionStatement = conn.prepareStatement(COMMIT_SQL);
		rollbackTransactionStatement = conn.prepareStatement(ROLLBACK_SQL);
		maxRidStatement = conn.prepareStatement(MAX_RID_SQL);
		numReservationsStatement = conn.prepareStatement(NUM_RESERVATIONS_SQL);
		addReservationStatement = conn.prepareStatement(ADD_RESERVATION_SQL);
		customerResevationsStatement = conn.prepareStatement(CUSTOMER_RESERVATIONS_SQL);
		specificReservationStatement = conn.prepareStatement(SPECIFIC_RESERVATION_SQL);
		cancelReservatoinStatement = conn.prepareStatement(CANCEL_RESERVATION_SQL);
		conflictFlightsStatement = conn.prepareStatement(CONFLICT_FLIGHTS_SQL);

		/* add here more prepare statements for all the other queries you need */
		loginStatement = conn.prepareStatement(LOGIN_SQL);
		searchTwoHopStatement = conn.prepareStatement(SEARCH_TWO_HOP_SQL);
		/* . . . . . . */
	}
	
	public void transaction_login(String username, String password) throws Exception {
            // Add code here
		// reset the latest flights id's, since searches are user specific
		lastSearchFids = new HashMap<Integer, int[]>();

		// set the parameters then excute the query
		loginStatement.clearParameters();
		loginStatement.setString(1, username);
		loginStatement.setString(2, password);
		ResultSet loginResults = loginStatement.executeQuery();
	
		// make sure that one and only one user has this name-password combination
		if(loginResults.next()){
			// extract one result
			cid = loginResults.getInt(1);
			this.username = username;

			// if there is still another row
			if(loginResults.next())
				System.out.println("More than one user with said name-password combination");
			else
				System.out.println("loggedin for user: " + this.username + " with id: " + cid);
		} else {
			System.out.println("No such user exists");
		}

		// close
		loginResults.close();
	}

	/** Various helper methods that might or might not be helpful
		tbh as of yet I am thinking only about one helper method but might as well add an entier section
	*/

	// returns an id for a reservation that is guranteed not to exist within the set of
	// currently existing reservations
	public int getReservationID() throws Exception{

		maxRidStatement.clearParameters();
		ResultSet maxRidResults = maxRidStatement.executeQuery();

		int uniqueRid = 1;
		// only in the case that the reservation table is not empty
		if(maxRidResults.next())
			uniqueRid = maxRidResults.getInt(1) + 1;

		// close
		maxRidResults.close();

		return uniqueRid;
	}

	// returns the number of reservations with the given flightid
	public int getNumReservatoinsIn(int itineraryId) throws Exception{

		numReservationsStatement.clearParameters();
		numReservationsStatement.setInt(1, itineraryId);
		ResultSet numReservationsResults = numReservationsStatement.executeQuery();

		int numReservations = 0;
		// make sure that there are results
		if(numReservationsResults.next())
			numReservations = numReservationsResults.getInt(1);

		// close
		numReservationsResults.close();

		return numReservations;
	}

	// returns true if and only if the given reservatoin id exists
	// and belonges to the given user
	public boolean reservationExists(int reservationID, int customerID) throws Exception{

		specificReservationStatement.clearParameters();
		specificReservationStatement.setInt(1, reservationID);
		specificReservationStatement.setInt(2, customerID);
		ResultSet specificReservationResults = specificReservationStatement.executeQuery();

		// there exist such a reservation
		// the boolean answer returned is to be saved in a variable instead of directly 
		// returned for out need to clsoe the transaction before returning the asnwer 
		// but after getting the answer
		boolean belonges =  specificReservationResults.next();

		// close 
		specificReservationResults.close();

		return belonges;
	}

	// returns true if the given costumer has a reserved flight on the same date as 
	// the given flight
	public boolean hasConflictingFlight(int flightID, int customerID) throws Exception{

		conflictFlightsStatement.clearParameters();
		conflictFlightsStatement.setInt(1, flightID);
		conflictFlightsStatement.setInt(2, customerID);
		ResultSet conflictFlightsResults = conflictFlightsStatement.executeQuery();

		// there exist such a reservation 
		boolean hasConflict =  conflictFlightsResults.next();

		// close 
		conflictFlightsResults.close();

		return hasConflict;
	}
	/**
	 * Searches for flights from the given origin city to the given destination
	 * city, on the given day of the month. If "directFlight" is true, it only
	 * searches for direct flights, otherwise is searches for direct flights
	 * and flights with two "hops". Only searches for up to the number of
	 * itineraries given.
	 * Prints the results found by the search.
	 */
	public void transaction_search_safe(String originCity, String destinationCity, boolean directFlight, int dayOfMonth, int numberOfItineraries) throws Exception {

		// reset the latest flights id's
		lastSearchFids = new HashMap<Integer, int[]>();

		// no transaction is specifically needed since the search funciton only reads from the flights
		// table which cannot be altered by any other function. 

		// one hop itineraries
		searchOneHopStatement.clearParameters();
		searchOneHopStatement.setInt(1, numberOfItineraries);
		searchOneHopStatement.setString(2, originCity);
		searchOneHopStatement.setString(3, destinationCity);
		searchOneHopStatement.setInt(4, dayOfMonth);
		ResultSet oneHopResults = searchOneHopStatement.executeQuery();

		// count how many one hope results are there
		int countOneHop = 0;

		while (oneHopResults.next()) {
        	int result_year = oneHopResults.getInt("year");
        	int result_monthId = oneHopResults.getInt("month_id");
        	int result_dayOfMonth = oneHopResults.getInt("day_of_month");
            String result_carrierId = oneHopResults.getString("carrier_id");
            String result_flightNum = oneHopResults.getString("flight_num");
            String result_originCity = oneHopResults.getString("origin_city");
            int result_time = oneHopResults.getInt("actual_time");
            System.out.println("Flight: " + result_year + "," + result_monthId + "," + result_dayOfMonth + "," + result_carrierId + "," + result_flightNum + "," + result_originCity + "," + result_time);
  			
  			// get the fid and add it to the list
  			int flight_id = oneHopResults.getInt("fid");
  			int[] date = {result_year, result_monthId, result_dayOfMonth};
  			lastSearchFids.put(flight_id, date);

            countOneHop++;
  		}
		oneHopResults.close();

                // Add code here

		// determine the number of itineraries to be displayed
 		int twoHopNum = Math.max(numberOfItineraries-countOneHop, 0);

 		if(!directFlight){
 			// inject parameters then excute
 			searchTwoHopStatement.clearParameters();
			searchTwoHopStatement.setInt(1, twoHopNum);
			searchTwoHopStatement.setString(2, originCity);
			searchTwoHopStatement.setString(3, destinationCity);
			searchTwoHopStatement.setInt(4, dayOfMonth);
			ResultSet twoHopResults = searchTwoHopStatement.executeQuery();
			
			// print results
			while (twoHopResults.next()) {
				// extract result
				int rFid_f1 = twoHopResults.getInt("fid_f1");
				String rNum_f1 = twoHopResults.getString("nf1");
				String rOriginCity_f1 = twoHopResults.getString("oc_f1");
				String rDestCity_f1 = twoHopResults.getString("dc_f1");
				int rYear_f1 = twoHopResults.getInt("yf1");
				int rMonth_f1 = twoHopResults.getInt("mf1");
				int rDay_f1 = twoHopResults.getInt("df1");
				int rFid_f2 = twoHopResults.getInt("fid_f2");
				String rNum_f2 = twoHopResults.getString("nf2");
				String rOriginCity_f2 = twoHopResults.getString("oc_f2");
				String rDestCity_f2 = twoHopResults.getString("dc_f2");
				int rYear_f2 = twoHopResults.getInt("yf2");
				int rMonth_f2 = twoHopResults.getInt("mf2");
				int rDay_f2 = twoHopResults.getInt("df2");
				int result_time = twoHopResults.getInt("total");

	            
	            // print the results
	            System.out.println("First Flight \n\tid: " + rFid_f1 + ", Flight Num: " + rNum_f1 
	            					+ ", Origin city: " + rOriginCity_f1 + ", Dest city: " + rDestCity_f1);
	            System.out.println("Second Flight \n\tid: " + rFid_f2 + ", Flight Num: " + rNum_f2 
	            					+ ", Origin city: " + rOriginCity_f2 + ", Dest city: " + rDestCity_f2);
	            System.out.println("Total Flight Time: " + result_time + "\n");
  			
	            // add the flight's id's
	            int[] dateF1 = {rYear_f1, rMonth_f1, rDay_f1};
	            int[] dateF2 = {rYear_f2, rMonth_f2, rDay_f2};
	            lastSearchFids.put(rFid_f1, dateF1);
	            lastSearchFids.put(rFid_f2, dateF2);

	            // decrease the number of results
	            twoHopNum--;
  			}
			twoHopResults.close();
			
 		}

 		// in case no results was returned
 		if(twoHopNum == numberOfItineraries)
				System.out.println("No flights were found");
	}
	
	public void transaction_search_unsafe(String originCity, String destinationCity, boolean directFlight, int dayOfMonth, int numberOfItineraries) throws Exception {

            // one hop itineraries
            String unsafeSearchSQL =
                "SELECT TOP (" + numberOfItineraries +  ") year,month_id,day_of_month,carrier_id,flight_num,origin_city,actual_time "
                + "FROM Flights "
                + "WHERE origin_city = \'" + originCity + "\' AND dest_city = \'" + destinationCity +  "\' AND day_of_month =  " + dayOfMonth + " "
                + "ORDER BY actual_time ASC";

            System.out.println("Submitting unsafe query: " + unsafeSearchSQL);
            Statement searchStatement = conn.createStatement();
            ResultSet oneHopResults = searchStatement.executeQuery(unsafeSearchSQL);

            while (oneHopResults.next()) {
                int result_year = oneHopResults.getInt("year");
                int result_monthId = oneHopResults.getInt("month_id");
                int result_dayOfMonth = oneHopResults.getInt("day_of_month");
                String result_carrierId = oneHopResults.getString("carrier_id");
                String result_flightNum = oneHopResults.getString("flight_num");
                String result_originCity = oneHopResults.getString("origin_city");
                int result_time = oneHopResults.getInt("actual_time");
                System.out.println("Flight: " + result_year + "," + result_monthId + "," + result_dayOfMonth + "," + result_carrierId + "," + result_flightNum + "," + result_originCity + "," + result_time);
            }
            oneHopResults.close();
        }

	public void transaction_book(int itineraryId) throws Exception {
            // Add code here

		// makes sure the user is logged in
		if(username == null || cid == null){
			System.out.println("You have to sign in before booking a flight");
			return;
		}

		// make sure that the given itineraryId was in the last search
		if(lastSearchFids == null || !lastSearchFids.containsKey(itineraryId)){
			System.out.println("You can only book flights from your latest search");
			return;
		}


		try{
			// we need a transaction because the number of reservations that have been made
			// could be changed by other users, for instance. 
			beginTransaction();

			// make sure that no more than CAPACITY other people booked this flight
			// get the number of reservations in the given flight
			int numReservations = getNumReservatoinsIn(itineraryId);
			if(numReservations >= CAPACITY){
				rollbackTransaction();
				System.out.println("This flight is booked out, no more than " + CAPACITY + " people can book the same flight");
				return;
			}

			// make sure this user does not have another flight in the same date
			if(hasConflictingFlight(itineraryId, cid)){
				rollbackTransaction();
				System.out.println("You have a reserved flight on the same date");
				return;
			}

			// book the flight
			// get a unique reservation id, the flight id, and the user id
			int uniqueRreservatioinID = getReservationID();
			int flightID = itineraryId;
			int customerID = cid;
			int[] flightDate = lastSearchFids.get(flightID);
			int flightYear = flightDate[0];
			int flightMonth = flightDate[1];
			int flightDay = flightDate[2];


			// book the flight
			addReservationStatement.clearParameters();
			addReservationStatement.setInt(1, uniqueRreservatioinID);
			addReservationStatement.setInt(2, customerID);
			addReservationStatement.setInt(3, flightID);
			addReservationStatement.setInt(4, flightYear);
			addReservationStatement.setInt(5, flightMonth);
			addReservationStatement.setInt(6, flightDay);
			addReservationStatement.executeUpdate();

			// commit
			commitTransaction();
			
			System.out.println("Itinerary booked successfully for user " + username + " in flight " + flightID);
		}
		catch (SQLException e1){
			try{
				rollbackTransaction();
			} catch (SQLException w2){
				return;
			}
		}
	}

	public void transaction_reservations() throws Exception {
               // Add code here
		// makes sure the user is logged in
		if(username == null || cid == null){
			System.out.println("You have to sign in before looking at your reservatoins");
			return;
		}

		// we need a transaction here because the same user, logged on the same account
		// but on multiple machines, could alter the results of the reading with a write
		// command either by booking or canceling a reservation
		beginTransaction();

		// get the costumer's reservations
		customerResevationsStatement.clearParameters();
		customerResevationsStatement.setInt(1, cid);
		ResultSet costumerReservationsResults = customerResevationsStatement.executeQuery();

		commitTransaction();

		// counter to the number of results
		int reservationsCounter = 0;
		while (costumerReservationsResults.next()) {
        	int reservatoinID = costumerReservationsResults.getInt("rid");
        	int flightID = costumerReservationsResults.getInt("fid");
            System.out.println("Reservation: " + reservatoinID + " in Flight: " + flightID);

            // increament the counter
            reservationsCounter++;
  		}

  		// close
		costumerReservationsResults.close();  		

		// if no reservations exist
		if(reservationsCounter == 0)
			System.out.println("You don't have any reservations booked");
	}

	public void transaction_cancel(int reservationId) throws Exception {
               // Add code here

		// makes sure the user is logged in
		if(username == null || cid == null){
			System.out.println("You have to sign in before canceling a reservation");
			return;
		}

		try{
			// we need a transaction here because the rows of reservation could be changed by other functions
			beginTransaction();

			// make sure the given reservation belongs to this user
			if(!reservationExists(reservationId, cid)){
				rollbackTransaction();
				System.out.print("You have to make a reservation before canceling it");
				return;
			}

			// cancel the reservation
			cancelReservatoinStatement.clearParameters();
			cancelReservatoinStatement.setInt(1, reservationId);
			cancelReservatoinStatement.executeUpdate();

			// commit
			commitTransaction();
		} catch(SQLException e1){
			try{
				rollbackTransaction();
			} catch(SQLException e2){
				return;
			}
		}

		System.out.println("Reservatoin " + reservationId + " for user " + username + " was canceled successfully");
	}

    
       public void beginTransaction() throws Exception {
            conn.setAutoCommit(false);
            beginTransactionStatement.executeUpdate();  
        }

        public void commitTransaction() throws Exception {
            commitTransactionStatement.executeUpdate(); 
            conn.setAutoCommit(true);
        }
        public void rollbackTransaction() throws Exception {
            rollbackTransactionStatement.executeUpdate();
            conn.setAutoCommit(true);
            } 

}
