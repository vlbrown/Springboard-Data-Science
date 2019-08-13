/*
  Vicki Brown - August 12, 2019
*/

/* Welcome to the SQL mini project. For this project, you will use
Springboard's online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
  FROM Facilities 
  WHERE membercost > 0
;

/* Q2: How many facilities do not charge a fee to members? */

SELECT * 
  FROM Facilities 
  WHERE membercost = 0
;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
    facid, name, membercost, monthlymaintenance, 
    (.2 * monthlymaintenance) as twentyPercent 
  FROM 
    Facilities 
  WHERE 
    membercost < (.2 * monthlymaintenance)
;


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
  FROM Facilities 
  WHERE facid in (1,5)
;

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 
    name, monthlymaintenance, (
    CASE WHEN (monthlymaintenance > 100) 
      THEN 
        'expensive' 
      ELSE 
        'cheap' 
      END) AS cost 
  FROM 
    Facilities
;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

/*
  Note: The (s) on member(s) makes this question ambiguous. We're not asked 
  for the most recent member (where we could just sort the data and ignore 
  time of day). We're not asked for the last n (e.g., 5) members (where we 
  might have multiple days of joining). So... I will make the assumption that
  we are looking for the most recent day in which 1 or more members joined.
*/

SELECT 
     firstname, surname, substr(joindate,1,10) as joined_on 
 FROM 
     Members 
 WHERE 
     substr(joindate,1,10) 
 LIKE (
     SELECT 
         substr(max(joindate),1,10) as joined_on
    FROM 
        Members
   )
;


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/*
  N.B. To use || with MySQL, set the following first
    SET sql_mode='ANSI';
*/

SET sql_mode='ANSI';

SELECT DISTINCT name as Facility, surname || ', ' || firstname as Member_name
  FROM 
     Bookings 
     JOIN Facilities 
     ON
       Bookings.facid = Facilities.facid
     JOIN Members
     ON 
       Bookings.memid = Members.memid
  WHERE 
     Facilities.name LIKE 'Tennis Court%'
  ORDER BY Facility, Member_name
;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name as Facility, 
         surname || ', ' || firstname as Member_name, (
         CASE WHEN (Bookings.memid > 0) 
           THEN 
            (slots * Facilities.membercost)  
           ELSE 
            (slots * Facilities.guestcost) 
         END) AS cost 
  FROM
     Bookings 
     JOIN Facilities 
     ON
       Bookings.facid = Facilities.facid
     JOIN Members
     ON 
       Bookings.memid = Members.memid
  WHERE
     Bookings.starttime LIKE '2012-09-14%'
  ORDER BY
     cost DESC
;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT Facility, Member_name, cost
  FROM (
      SELECT name as Facility, (
         CASE WHEN (Bookings.memid > 0) 
           THEN 
            (surname || ', ' || firstname)
           ELSE
            'Guest'
         END) AS Member_name, (
         CASE WHEN (Bookings.memid > 0) 
           THEN 
            (slots * Facilities.membercost) 
           ELSE 
            (slots * Facilities.guestcost) 
          END) AS cost 
      FROM
         Bookings 
      JOIN Facilities 
      ON
         Bookings.facid = Facilities.facid
      JOIN Members
      ON 
         Bookings.memid = Members.memid
      WHERE
         Bookings.starttime LIKE '2012-09-14%'
  ) as sub
  WHERE 
    (cost > 30)
  ORDER BY
     cost DESC
;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name as facility, SUM(
    CASE WHEN (Bookings.memid > 0) 
        THEN 
          (slots * Facilities.membercost) 
        ELSE 
          (slots * Facilities.guestcost) 
       END) AS revenue 
  FROM 
       Bookings JOIN Facilities ON
       Bookings.facid = Facilities.facid     
  GROUP BY Facilities.name
  ORDER BY revenue
;
