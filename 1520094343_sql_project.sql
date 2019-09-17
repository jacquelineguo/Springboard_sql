/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
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
select name from Facilities where membercost != 0;

/* Q2: How many facilities do not charge a fee to members? */
select count(name) from Facilities where membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select * from Facilities where membercost != 0 and membercost < monthlymaintenance*0.2;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities where facid in (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, 
case when monthlymaintenance > 100 then 'expensive'
else 'cheap' end as c_or_e
from Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname, surname from Members where joindate = (select max(joindate) from Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT concat(D.name, ",", F.name) as ANSWER
from Facilities as F join (
select distinct concat(Members.firstname, " ", Members.surname) as name, Bookings.facid
from Members join Bookings
on Bookings.memid = Members.memid
where Bookings.facid in (select facid from Facilities where Facilities.name like 'Tennis%')) as D
on F.facid = D.facid
order by D.name;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select distinct F.name, concat(M.firstname, " ", M.surname), B.slots * (case when B.memid = 0 then F.guestcost else F.membercost end) as cost
from (Bookings as B join Facilities as F) join Members as M
on B.facid = F.facid and M.memid = B.memid
where starttime between '2012-09-14 00:00:00' and '2012-09-15 00:00:00'
and
B.slots * (case when B.memid = 0 then F.guestcost else F.membercost end) > 30
order by cost desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select distinct F.name, concat(M.firstname, " ", M.surname), B.slots * (case when B.memid = 0 then F.guestcost else F.membercost end) as cost
from ((select * from Bookings where starttime between '2012-09-14 00:00:00' and '2012-09-15 00:00:00') as B join Facilities as F) join Members as M
on B.facid = F.facid and M.memid = B.memid
where B.slots * (case when B.memid = 0 then F.guestcost else F.membercost end) > 30
order by cost desc;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select final.name, final.revenue
from
(select derived.facid, derived.name as name, sum(derived.rev) as revenue
from
(select B.facid, F.name, B.slots * (case when B.memid = 0 then F.guestcost else F.membercost end) as rev
from Bookings as B join Facilities as F
on B.facid = F.facid) as derived
group by derived.facid) as final
where final.revenue < 1000
order by final.revenue

