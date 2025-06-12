/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
select 'director_mapping' AS table_name, count(1) as num_of_rows from director_mapping dm
union
select 'genre', count(1) as num_of_rows from genre gr
union
select 'movie', count(1) as num_of_rows from movie mv
union
select 'names', count(1) as num_of_rows from names nm
union
select 'ratings', count(1) as num_of_rows from ratings rt
union
select 'role_mapping', count(1) as num_of_rows from role_mapping rm;

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
select all_col.column_name, sum(case when all_col.column_value is null then 1 else 0 end) as num_null
from(
	select 'id' as column_name, mv.id::text as column_value from movie mv
	union all
	select 'title' as column_name, mv.title::text as column_value from movie mv
	union all
	select 'year' as column_name, mv.year::text as column_value from movie mv
	union all
	select 'date_published' as column_name, mv.date_published::text as column_value from movie mv
	union all
	select 'durration' as column_name, mv.duration::text as column_value from movie mv
	union all
	select 'country' as column_name, mv.country::text as column_value from movie mv
	union all
	select 'worlwide_gross_income' as column_name, mv.worlwide_gross_income::text as column_value from movie mv
	union all
	select 'languages' as column_name, mv.languages::text as column_value from movie mv
	union all
	select 'production_company' as column_name, mv.production_company::text as column_value from movie mv
) all_col
group by all_col.column_name
having sum(case when all_col.column_value is null then 1 else 0 end) > 0;


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- The first part
select mv."year" as "Year", count(*) as number_of_movies
from movie mv 
group by mv."year" 
order by mv."year" asc;

-- The second part
select extract(month from mv.date_published) as month_num, count(*) as number_of_movies
from movie mv 
group by extract(month from mv.date_published)
order by extract(month from mv.date_published) asc;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

select count(1) as number_of_movies
from movie mv
where (mv.country like '%India%' or mv.country like '%USA%') and mv."year" = 2019


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
select distinct(gr.genre)
from genre gr;


/* So, Bee Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

select gr.genre, count(*) as movie_count
from genre gr 
group by gr.genre
order by movie_count desc 
limit 1;

/* So, based on the insight that you just drew, Bee Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

select count(1) as one_genre_movie_count
from(
	select gr.movie_id, count(*)
	from genre gr 
	group by gr.movie_id
	having count(*) = 1 
);

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of Bee Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select mv_gr.genre, round(avg(mv_gr.duration), 2) as avg_duration
from(
	select mv.*, gr.genre 
	from movie mv
	join genre gr on gr.movie_id = mv.id 
)mv_gr 
group by mv_gr.genre
order by avg_duration desc;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below: 
select ranked_genre.* 	
from(
	select gr.genre, count(*) as movie_count, 
			rank() over(order by count(*) desc) as genre_rank
	from genre gr
	group by gr.genre 
)ranked_genre
where ranked_genre.genre = 'Thriller';

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

select min(rt.avg_rating) as min_avg_rating, max(rt.avg_rating) as max_avg_rating, 
		min(rt.total_votes) as min_total_votes, max(rt.total_votes) as max_total_votes,
		min(rt.median_rating) as min_median_rating, max(rt.median_rating) as max_median_rating
from ratings rt;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
select rank_movie.*
from(
	select mv.title, rt.avg_rating,
		rank() over(order by rt.avg_rating desc) as movie_rank
	from ratings rt
	join movie mv on mv.id = rt.movie_id
)rank_movie
where rank_movie.movie_rank <= 10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
select rt.median_rating, count(*) as movie_count
from ratings rt
group by rt.median_rating 
order by rt.median_rating asc;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which Bee Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
select prod_count_movie.*
from(
	select mv.production_company, count(*) movie_count, 
		rank() over(order by count(*) desc) as prod_company_rank
	from movie mv 
	join ratings rt on rt.movie_id = mv.id 
	where rt.avg_rating > 8 and mv.production_company is not null
	group by mv.production_company 
)prod_count_movie
where prod_count_movie.prod_company_rank = 1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
select gr.genre, count(*) as movie_count
from movie mv
join genre gr on gr.movie_id  = mv.id 
join ratings rt on rt.movie_id = mv.id
where mv.country like '%USA%' and mv."year" = 2017 and extract(month from mv.date_published) = 3 and rt.total_votes > 1000
group by gr.genre
order by movie_count desc;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

select mv.title, rt.avg_rating, gr.genre
from movie mv
join genre gr on gr.movie_id  = mv.id 
join ratings rt on rt.movie_id = mv.id
where mv.title like 'The %' and rt.avg_rating > 8
order by rt.avg_rating desc;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
select mv.title, rt.median_rating, gr.genre
from movie mv
join genre gr on gr.movie_id  = mv.id 
join ratings rt on rt.movie_id = mv.id
where mv.title like 'The %' and rt.median_rating > 8;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

select count(1) as movie_count
from movie mv 
join ratings rt on rt.movie_id = mv.id 
where (mv.date_published between '2018-04-01' and '2019-04-01') and rt.median_rating = 8;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

select 'Germany' as country, sum(rt.total_votes) as movie_vote
from movie mv 
join ratings rt on rt.movie_id = mv.id 
where mv.country like '%Germany%'
union 
select 'Italy' as country, sum(rt.total_votes) as movie_vote
from movie mv 
join ratings rt on rt.movie_id = mv.id 
where mv.country like '%Italy%'

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select sum(case when nm."name" is null then 1 else 0 end) as name_nulls,
		sum(case when nm."height" is null then 1 else 0 end) as height_nulls,
		sum(case when nm.date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
		sum(case when nm.known_for_movies is null then 1 else 0 end) as known_for_movies_nulls 
from names nm;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by Bee Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
select nm."name" as director_name, ranked_director.movie_count
from(
	select statistic.name_id, count(*) as movie_count, dense_rank() over(order by count(*) desc) as director_rank
	from(
		select mv_gr.id, mv_gr.title, mv_gr.genre, director.name_id, director."name" as director_name, mv_gr.avg_rating
		
		-- 	Top 3 genres with num of movies (avg_rating > 8)	
		from(
			select gr.genre, count(*) as movie_count,
					rank() over(order by count(*) desc) as movie_count_rank
			from ratings rt 
			join genre gr on gr.movie_id = rt.movie_id 
			where rt.avg_rating > 8
			group by gr.genre 
		)count_genre
		
		-- Movies with their genres and avg_rating 
		join(
			select mv.*, gr.genre, rt.avg_rating 
			from movie mv 
			join genre gr on gr.movie_id = mv.id
			join ratings rt on rt.movie_id = mv.id
			where rt.avg_rating > 8
		)mv_gr on mv_gr.genre = count_genre.genre
		
		-- Movies with their director names
		join (
			select dm.movie_id, dm.name_id, nm."name"
			from director_mapping dm
			join names nm on nm.id = dm.name_id 
		)director on director.movie_id = mv_gr.id
		where count_genre.movie_count_rank <= 3
	)statistic 
	
	-- group by director name to count num of movies that they direct
	group by statistic.name_id -- ,statistic.title lọc 1 phim có nhiều thể loại thì ẫn chỉ tính 1 phim
)ranked_director
join names nm on nm.id = ranked_director.name_id 
where ranked_director.director_rank <= 3
order by ranked_director.movie_count desc; 

/* James Mangold can be hired as the director for Bee's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select nm."name" as actor_name, ranked_actor.movie_count
from(
	select fact_movie.name_id, count(*) as movie_count,
			rank() over(order by count(*) desc) as r_actor 
	from (
		select mv.*, rm.name_id, nm."name" as actor_name, rt.median_rating
		from movie mv 
		join role_mapping rm on rm.movie_id = mv.id 
		join names nm on nm.id = rm.name_id 
		join ratings rt on rt.movie_id = mv.id 
		where rm.category = 'actor'
	) fact_movie 
	where fact_movie.median_rating >= 8
	group by fact_movie.name_id
) ranked_actor 
join names nm on nm.id = ranked_actor.name_id 
where ranked_actor.r_actor <= 2
order by ranked_actor.movie_count desc;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
Bee Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
select ranked_comp.production_company, ranked_comp.vote_count, ranked_comp.prod_comp_rank
from(
	select fact_movie.production_company, sum(fact_movie.total_votes) as vote_count,
		rank() over(order by sum(fact_movie.total_votes) desc) as prod_comp_rank
	from(
		select mv.*, rt.total_votes 
		from movie mv
		join ratings rt on rt.movie_id = mv.id 
	)fact_movie
	group by fact_movie.production_company
) ranked_comp
where ranked_comp.prod_comp_rank <= 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since Bee Movies is based out of Mumbai, India also wants to woo its local audience. 
Bee Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select nm."name" as actor_name, fct_actor.total_votes, fct_actor.movie_count, fct_actor.actor_avg_rating, 
		rank() over(order by fct_actor.actor_avg_rating desc, fct_actor.total_votes desc) as actor_rank
from(
	select fact_movie.name_id, sum(fact_movie.total_votes) as total_votes, count(*) as movie_count, 
			round((sum(fact_movie.avg_rating * fact_movie.total_votes) * 1.0 / sum(fact_movie.total_votes)), 2) as actor_avg_rating
	from(
		select mv.*, rm.name_id, nm."name" as actor, rt.avg_rating, rt.total_votes 
		from movie mv 
		join role_mapping rm on rm.movie_id = mv.id
		join ratings rt on rt.movie_id = mv.id
		join names nm on nm.id = rm.name_id
		where rm.category = 'actor'
		order by mv.id
	) fact_movie
	where fact_movie.country like '%India%' 
	group by fact_movie.name_id
	having count(*) >= 5
)fct_actor
join names nm on nm.id = fct_actor.name_id 
order by actor_rank asc; 

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select nm."name" as actress_name, ranked_actress.total_votes, ranked_actress.movie_count, ranked_actress.actress_avg_rating, ranked_actress.actress_rank
from(
	select fct_actress.name_id, fct_actress.total_votes, fct_actress.hindi_movie_count as movie_count, fct_actress.actress_avg_rating,
			rank() over(order by fct_actress.actress_avg_rating desc, fct_actress.total_votes desc) as actress_rank
	from(
		select fact_movie.name_id, sum(fact_movie.total_votes) as total_votes, 
				sum(case when fact_movie.country like '%India%' then 1 else 0 end) as india_movie_count, 
				sum(case when fact_movie.country like '%India%' and fact_movie.languages like '%Hindi%' then 1 else 0 end) as hindi_movie_count,
				round((sum(fact_movie.avg_rating*fact_movie.total_votes)*1.0 / sum(fact_movie.total_votes)), 2) as actress_avg_rating
		from(
			select mv.*, rm.name_id, nm."name" as actress, rt.avg_rating, rt.total_votes 
			from movie mv 
			join role_mapping rm on rm.movie_id = mv.id
			join ratings rt on rt.movie_id = mv.id
			join names nm on nm.id = rm.name_id
			where rm.category = 'actress' and mv.country like '%India%' and mv.languages like '%Hindi%'
			order by mv.id
		) fact_movie
		group by fact_movie.name_id
		having count(case when fact_movie.country like '%India%' and fact_movie.languages like '%Hindi%' then 1 else null end) >= 3
	)fct_actress
	where fct_actress.hindi_movie_count > 0 
)ranked_actress
join names nm on nm.id = ranked_actress.name_id 
where actress_rank <= 5
order by ranked_actress.movie_count desc;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

select fct_thriller_movie.id, fct_thriller_movie.title, rt.avg_rating,
	case
		when rt.avg_rating > 8 then 'Superhit movies'
		when rt.avg_rating between 7 and 8 then 'Hit movies'
		when rt.avg_rating between 5 and 7 then 'One-time-watch movies'
		when rt.avg_rating < 5 then 'Flop movies'
	end as category
from(
	select mv.*, gr.genre
	from movie mv 
	join genre gr on gr.movie_id = mv.id 
	where gr.genre = 'Thriller'
)fct_thriller_movie 
join ratings rt on rt.movie_id = fct_thriller_movie.id 
order by category desc;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select fact_genre.genre, fact_genre.avg_duration,
           sum(fact_genre.avg_duration) over (order by fact_genre.genre rows between unbounded preceding and current row) as running_total_duration,
           round(avg(avg_duration) over (order by fact_genre.genre rows between 2 preceding and current row), 2) as moving_avg_duration
from(
	select gr.genre, round(avg(mv.duration), 2) as avg_duration
    from genre gr
    join movie mv on gr.movie_id = mv.id
    group by gr.genre
)fact_genre;
-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select *
from(
	select fct_movie_t3g.genre, fct_movie_t3g."year", fct_movie_t3g.title as movie_name, fct_movie_t3g.worlwide_gross_income, 
		rank() over(partition by fct_movie_t3g.genre, fct_movie_t3g."year" order by fct_movie_t3g.worlwide_gross_income desc) movie_rank
	-- Filter out movie with top 3 genre
	from(
		select fct_movie.*
		from (
			select mv.*, gr.genre 
			from movie mv 
			join genre gr on gr.movie_id = mv.id
		)fct_movie
		-- Top 3 Genres based on most number of movies
		join(
			select gr.genre, count(*)
			from movie mv 
			join genre gr on gr.movie_id = mv.id 
			group by gr.genre
			order by count(*) desc
			limit 3
		)top3_genre on top3_genre.genre = fct_movie.genre
	)fct_movie_t3g
	where fct_movie_t3g.worlwide_gross_income is not null
)rank_movie 
where rank_movie.movie_rank <=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
select*
from(
	select mv.production_company, count(*) as movie_count, 
			rank() over(order by count(*) desc) as prod_comp_rank
	from movie mv 
	join ratings rt on rt.movie_id = mv.id 
	where position(',' in mv.languages) > 0 and mv.production_company is not null and rt.median_rating >= 8
	group by mv.production_company 
)
where  prod_comp_rank <= 2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select nm."name" as actress_name, ranked_actress.total_votes, ranked_actress.movie_count, ranked_actress.actress_avg_rating, ranked_actress.actress_rank
from(
	select fact_actress.name_id, fact_actress.total_votes, fact_actress.movie_count, fact_actress.actress_avg_rating,
	    rank() over(order by fact_actress.movie_count desc) as actress_rank
	from(
		select fact_movie.name_id, sum(fact_movie.total_votes) as total_votes, count(*) as movie_count, 
		    round((sum(fact_movie.avg_rating*fact_movie.total_votes)*1.0 / sum(fact_movie.total_votes)), 2) as actress_avg_rating
		from (
		    select mv.*, rm.name_id, nm."name" as actress_name, rt.avg_rating, rt.total_votes
		    from movie mv
		    join genre gr on gr.movie_id = mv.id
		    join ratings rt on rt.movie_id = mv.id
		    join role_mapping rm on rm.movie_id = mv.id
		    join names nm on nm.id = rm.name_id
		    where gr.genre = 'Drama' and rt.avg_rating > 8 and rm.category = 'actress'
		) fact_movie
		group by fact_movie.name_id
	) fact_actress
) ranked_actress
join names nm on nm.id = ranked_actress.name_id 
where ranked_actress.actress_rank <= 3
order by ranked_actress.actress_rank asc;



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

--Director id
--Name
--Number of movies
--Average inter movie duration in days 
--Average movie ratings
--Total votes 
--Min rating 
--Max rating 
--total movie durations

with avg_inter_days as (
    select inter_days.name_id, round(avg(inter_days.gap_days), 0) as avg_inter_movie_days
    from (
    	-- The gap between 2 latest movies
        select gap_movie.name_id, (gap_movie.date_published - gap_movie.prev_date) as gap_days
        -- The date of the previous movie
        from (
            select movie_dates.name_id, movie_dates.date_published,
                   lag(movie_dates.date_published) over (partition by movie_dates.name_id order by movie_dates.date_published) as prev_date
            -- Date_published of each movie
            from (
                select dm.name_id, mv.date_published
                from movie mv
                join director_mapping dm on mv.id = dm.movie_id
                where mv.date_published is not null
            ) as movie_dates
        ) as gap_movie
        where gap_movie.prev_date is not null
    ) as inter_days
    group by inter_days.name_id
)
select dir_infor.name_id as director_id, 
       nm."name" as director_name, 
       dir_infor.movie_count as number_of_movies, 
       coalesce(aid.avg_inter_movie_days::text, null) as avg_inter_movie_days, 
       dir_infor.avg_movie_rating as avg_rating, 
       dir_infor.total_votes, 
       dir_infor.min_rating, 
       dir_infor.max_rating,
       dir_infor.total_duration
from (
    select fact_movie.name_id, 
           count(*) as movie_count, 
           round((sum(fact_movie.avg_rating * fact_movie.total_votes) * 1.0 / sum(fact_movie.total_votes)), 2) as avg_movie_rating, 
           sum(fact_movie.total_votes) as total_votes, 
           avg(fact_movie.duration) as avg_duration, 
           min(fact_movie.avg_rating) as min_rating,
           max(fact_movie.avg_rating) as max_rating,
           sum(fact_movie.duration) as total_duration,
           rank() over(order by count(*) desc) as dir_rank
    from (
        select mv.*, dm.name_id, nm."name" as director_name, rt.avg_rating, rt.total_votes
        from movie mv
        join ratings rt on rt.movie_id = mv.id
        join director_mapping dm on dm.movie_id = mv.id
        join names nm on nm.id = dm.name_id
    ) fact_movie
    group by fact_movie.name_id
) dir_infor
join names nm on nm.id = dir_infor.name_id
left join avg_inter_days aid on dir_infor.name_id = aid.name_id
where dir_infor.dir_rank <= 9
order by number_of_movies desc;

