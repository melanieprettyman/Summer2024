# Homework 3: Scraping and Regression
## Due Friday, June 7

In this assignment we'll analyze some data from the tech news site [HackerNews](https://news.ycombinator.com).  HN has a nice simple HTML table format which makes our scraping less painful than some other websites.

## Part 1 Data Acquisition

Check out the robots.txt file for HN to make sure you're allowed to scrape it for stories.

Grab the first 5 pages of stories from hackernews.  For each story, grab the following data: 

* Rank (the number of the story on hacker news)
* Length of the title
* Age, in hours (note, some stories are days or minutes old.  You should be able to handle this)
* Points (note, some stories don't have scores! Give them 0 points)
* Number of comments (again, some stories have no comments.  Mark them 0)

A lot of HTML on HN has handy class attributes to help make this task a bit easier.  Once you have all your data, create a dataframe to store it, and save a CSV file so you don't have to hit the server repeatedly to reload the data.

Most of the table entries are nicely, uniformly formatted, but a few might be missing fields.  I'd suggest testing with the common case and fixing edge cases as they come up.

## Part 2 Regression

We're interested in how to get a high-ranking story on Hackernews.  Explore several possible least squares regressions to predict a story's rank based on the other variables (or combinations thereof).  Include at least 3 different regressions.  Compare/contrast them.  Which is the most useful.  Are there linear relationships between any of the variables?  How about other relationships like inverse linear (1/x)?

## Part 3 Classification

As smart people, we know that your rank on HN doesn't matter, as long as you're on the front page.  Use logistic regression to attempt to classify whether or not an article will be on the front page, given the other (non-rank) variables.  Note, you'll need to transform the rank variable into an indicator variable (1 for front page, 0 for not), for example.  

Include plots showing your regression (for the functions of 1 or 2 variables).  What do your regressions tell you about making the front page?

## Fun extra challenge

An outdated ranking formula for HN is publicly available.  Take a look at it and perform a regression using the true formula and see if least squraes regression can compute the coefficients correctly