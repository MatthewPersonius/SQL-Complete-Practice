/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.



Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name FROM `Facilities` WHERE `membercost`>0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) FROM `Facilities` WHERE `membercost`>0;
Result: 5



/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT `facid`, `name`, `membercost`, `monthlymaintenance` 
FROM `Facilities`
WHERE `membercost`>0 
AND (`membercost`/`monthlymaintenance`) *100 < 20;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM `Facilities` 
WHERE `facid`IN (1,5);

facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
1	Tennis Court 2	5.0	25.0	8000	200
5	Massage Room 2	9.9	80.0	4000	3000


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT `name`, 
CASE WHEN `monthlymaintenance` > 100 THEN 'expensive'
WHEN `monthlymaintenance` < 100 THEN 'cheap' END
AS `monthlymaintenance`
FROM `Facilities`;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT `firstname`,`surname`, `joindate`
FROM `Members`
ORDER BY `joindate` DESC;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT f.name AS name of court, m.firstname, m.surname,
FROM `Bookings` 
	FULL JOIN `Members` AS m
	USING (`memid`)
	FULL JOIN `Facilities` AS f
	USING (`facid`)
WHERE `facid`=0 OR `facid`=1
ORDER BY m.surname;


SELECT `Facilities`.name, `Members`.firstname, `Members`.surname,
FROM `Bookings` 
FULL JOIN `Members` 
ON `Bookings`.`memid`= `Members`.`memid`
FULL JOIN `Facilities` 
ON `Bookings`.`facid`=`Facilities`.`facid`
WHERE `Bookings`.`facid`=0 OR `Bookings`.`facid`=1;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
`firstname`, `surname` AS `member`,
`name` AS `facility`,
CASE WHEN `firstname` = 'GUEST' THEN `guestcost` * `slots` ELSE `membercost` * `slots` END AS cost
FROM `Members`
INNER JOIN `Bookings`
ON `Members`.`memid` = `Bookings`.`memid`
INNER JOIN `Facilities`
ON `Bookings`.`facid` = `Facilities`.`facid`
WHERE `starttime` >= '2012-09-14' AND `starttime` < '2012-09-15'
AND CASE WHEN `firstname` = 'GUEST' THEN `guestcost` * `slots` ELSE `membercost` * `slots` END > 30
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
`firstname`,`surname` AS member,
`name` AS `facility`,
`cost`
FROM
(SELECT
`firstname`,
`surname`,
`name`,
CASE WHEN `firstname` = 'GUEST' THEN `guestcost` * `slots` ELSE `membercost` * `slots` END AS cost,
`starttime`
FROM `Members`
INNER JOIN `Bookings`
ON `Members`.`memid` = `Bookings`.`memid`
INNER JOIN `Facilities`
ON `Bookings`.`facid` = `Facilities`.`facid`) AS inner_table
WHERE `starttime` >= '2012-09-14' AND `starttime` < '2012-09-15'
AND cost > 30
ORDER BY cost DESC;


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
`name`,
`revenue`
FROM
(SELECT
`name`,
SUM(CASE WHEN `memid` = 0 THEN `guestcost` * `slots` ELSE `membercost` * `slots` END) AS revenue
FROM `Bookings` INNER JOIN `Facilities`
ON `Bookings`.`facid` = `Facilities`.`facid`
GROUP BY `name`) AS inner_table
WHERE revenue < 1000
ORDER BY revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT concat(`m`.`firstname`,' ',`m`.`surname`) AS `Recommended By`,
concat(`r`.`firstname`,' ',`r`.`surname`) as `Member Who Joined`
FROM `Members` AS `m`
inner join `Members` `r` on `r`.`recommendedby` = `m`.`memid`
WHERE `m`.`memid` > 0 
order by `m`.`surname`,`m`.`firstname`,`r`.`surname`,`r`.`surname`;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT `Facilities`.`name`,concat(`Members`.`firstname`,' ',`Members`.`surname`) as `Member`,
count(`Facilities`.`name`) as `Bookings`
FROM `Members` 
INNER JOIN `Bookings` on `Bookings`.`memid` = `Members`.`memid`
INNER JOIN `Facilities` on `Facilities`.`facid` = `Bookings`.`facid`
where `Members`.`memid`>0
group by `Facilities`.`name`,concat(`Members`.`firstname`,' ',`Members`.`surname`)
order by `Facilities`.`name`,`Members`.`surname`,`Members`.`firstname`; 



/* Q13: Find the facilities usage by month, but not guests */

SELECT `Facilities`.`name`,concat(`Members`.`firstname`,' ',`Members`.`surname`) as Member,
count(`Facilities`.`name`) as bookings,

sum(case when month(`Bookings`.`starttime`) = 1 then 1 else 0 end) as Jan,
sum(case when month(`Bookings`.`starttime`) = 2 then 1 else 0 end) as Feb,
sum(case when month(`Bookings`.`starttime`) = 3 then 1 else 0 end) as Mar,
sum(case when month(`Bookings`.`starttime`) = 4 then 1 else 0 end) as Apr,
sum(case when month(`Bookings`.`starttime`) = 5 then 1 else 0 end) as May,
sum(case when month(`Bookings`.`starttime`) = 6 then 1 else 0 end) as Jun,
sum(case when month(`Bookings`.`starttime`) = 7 then 1 else 0 end) as Jul,
sum(case when month(`Bookings`.`starttime`) = 8 then 1 else 0 end) as Aug,
sum(case when month(`Bookings`.`starttime`) = 9 then 1 else 0 end) as Sep,
sum(case when month(`Bookings`.`starttime`) = 10 then 1 else 0 end) as Oct,
sum(case when month(`Bookings`.`starttime`) = 11 then 1 else 0 end) as Nov,
sum(case when month(`Bookings`.`starttime`) = 12 then 1 else 0 end) as Decm;

FROM `Members` 
inner join `Bookings`  on `Bookings`.`memid` = `Members`.`memid`
inner join `Facilities` on `Facilities`.`facid` = `Bookings`.`facid`
where `Members`.`memid`>0
and year(`starttime`) = 2012

group by `Facilities`.`name`,concat(`Members`.`firstname`,' ',`Members`.`surname`)
order by `Facilities`.`name`,`Members`.`surname`,`Members`.`firstname`;
