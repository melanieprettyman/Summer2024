# Homework 2

Due Friday, May 31

## Part 1: A/B Hypothesis testing

Adapted from datasciencecourse.net

Your boss wants you to see which of these 2 logos is better:

![logos](abTest.jpg)

You conduct an A/B test for your website by showing A to some of your users, and B to others.

| | ad clicks | total views |
|---|---|---|
|A| 500 | 1000 |
|B| 550 | 1000 |

It looks like B is better than A... 

Perform a hypothesis test using the two-proportion z-value test [See the "pooled" version from the table here](https://en.wikipedia.org/wiki/Test_statistic) statistic at both the 5% and 1% signficance levels.

Begin by formulating and writing down your null hypothesis, then compute the Z value for this trial, and its associated p-value.
 
Note: the Z value you compute is assumed to be distributed according to the standard normal distribution (mean = 0, variance = 1).  We'll consider the "1-sided" p-value which meaures the probability of a sample having a Z value that is more extreme in only one tail (to get the 2-sided value, you'd just multiply by 2).  
 
**What can you conclude?**
 
Note, to help you understand your results, you might want to tweak the number of clicks for b to see how that changes your results.  For example, what do you expect to happen to your p value if b is clicked 560 or 570 times?  This is JUST for understanding the results, and shouldn't bias your decision one way or another!


## Part 2: Regression of real estate data

Adapted from datasciencecourse.net

For this problem, you will analyze SLC real estate data. The dataset contains multiple listing service (MLS) real estate transactions for houses sold in 2015-16 in zip code 84103 (SLC avenues neighborhod [Google Map](https://www.google.com/maps/place/Salt+Lake+City,+UT+84103/@40.8030372,-111.8957957,12z/data=!3m1!4b1!4m5!3m4!1s0x87525f672006dded:0x311e638d9a1a2de5!8m2!3d40.810506!4d-111.8449346)). We are primarily interested in regressing the `SoldPrice` on the house attributes (property size, house size, number of bedrooms, etc...). 


### Task 1: Import the data 

Use the pandas.read_csv() function to import the dataset. The data is contained in two files: [realEstate1.csv](realEstate1.csv) and [realEstate2.csv](realEstate2.csv). After you import these files separately, concatenate them into one big dataframe. This pandas dataframe will be used for data exploration and linear regression. 
 
 
### Task 2: Clean the data 

+ There are 206 different variables associated with each of the 348 houses in this dataset. Skim them and try to get a rough understanding of what information this dataset contains. If you've never seen a real estate listing before, you might take a look at one on [this](http://www.utahrealestate.com/) website to get a better sense of the meanings of the column headers in the dataset.  

+ Only keep houses with List Price between 200,000 and 1,000,000 dollars. This is an arbitrary choice and we realize that some of you are high rollers, but for our purposes we'll consider the others as outliers. Also, this data is ~10 years old.  There DID use to be houses available for under $200k!

+ Remove columns that you don't think contribute to the value of the house. This is a personal decision - what attributes of a house are important to you? You should at least keep the following variables since the questions below will use them: ['Acres', 'Deck', 'GaragCap', 'Latitude', 'Longitude', 'LstPrice', 'Patio', 'PkgSpacs', 'PropType', 'SoldPrice', 'Taxes', 'TotBed', 'TotBth', 'TotSqf', 'YearBlt'] 

+ Check the datatypes and convert any numbers that were read as strings to numerical values. (Hint: You can use [str.replace()](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.str.replace.html) to work with strings.) If there are any categorical values you're interested in, then you should convert them to numerical values as we saw in the notes (the `get_dummies` function may help). In particular, convert 'TotSqf' to an integer and add a column titled Prop_Type_num that is 0 if i-th listing is a condo or townhouse, or 1 if i-th listing is a single family house

+ Remove the listings with erroneous 'Longitude' (one has Longitude = 0) and 'Taxes' values (at least two have unreasonably large values).


### Task 3: Exploratory data analysis 

+ Explore the dataset. Write a short description of the dataset describing the number of items, the number of variables and check to see if the values are reasonable. 

+ Make a bar chart showing the breakdown of the different types of houses (single family, townhouse, condo). 

+ Compute the correlation matrix and use a heat map to visualize the correlation coefficients. 
    - Use a diverging color scale from -1 to +1 (see vmin and vmax parameters for [pcolor](https://matplotlib.org/devdocs/api/_as_gen/matplotlib.pyplot.pcolor.html)
    - Show a legend (colorbar)
    - Make sure the proper labels are visible and readable (see [xticks](https://matplotlib.org/devdocs/api/_as_gen/matplotlib.pyplot.xticks.html) and the corresponding [yticks](https://matplotlib.org/devdocs/api/_as_gen/matplotlib.pyplot.yticks.html).

+ Make a scatter plot matrix to visualize the correlations. For the plot, only use a subset of the columns: ['Acres', 'LstPrice', 'SoldPrice', 'Taxes', 'TotBed', 'TotBth', 'TotSqf', 'YearBlt']. Determine which columns have strong correlations. 

+ Describing your findings. 


### Task 4: Geospatial plot

Two of the variables are the latitude and longitude of each listing. Salt Lake City is on this nice east-west, north south grid, so even a simple plot of lat and long makes sense. Create a scatterplot of these two variables. Use color to indicate the price of the house. How does the price depend on the house location?

Bonus: If you can, overlay the scatterplot on a map of the city. (This is challenging, and we didn't teach you how to do it, so you should do the other parts of the assignment first.)

What can you say about the relation between the location and the house price?


### Task 5: Simple  Linear Regression 

Use the 'ols' function from the [statsmodels](http://www.statsmodels.org/stable/index.html) package to regress the Sold price on some of the other variables. Your model should be of the form `Sold Price = beta_0 + beta_1 * x`, where x is one of the other variables. 

You'll find that the best predictor of sold price is the list price. Report the R-squared value for this model (`SoldPrice ~ LstPrice`) and give an interpretation for its meaning. Also give an interpretation of `beta_1` for this model. Make a plot of list price vs. sold price and overlay the prediction coming from your regression model. 

### Task 6: Multilinear Regression 

Develop a multilinear regression model for house prices in this neighborhood. We could use this to come up with a list price for houses coming on the market, so do not include the list price in your model and, for now, ignore the categorical variable Prop_Type. Your model should be of the form:

`Sold Price = beta_0 + beta_1 * x_1 + beta_2 * x_2 + ... +  beta_n * x_n `

where x_i are predictive variables. Which variables are the best predictors for the Sold Price? 

Specific questions:

+ Often the price per square foot for a house is advertised. Is this what the coefficient for TotSqf is measuring? Provide an interpretation for the coefficient for TotSqf.  
+ Estimate the value that each Garage space adds to a house. 
+ Does latitude or longitude have an impact on house price? Explain. 
+ If we wanted to start a 'house flipping' company, we'd have to be able to do a better job of predicting the sold price than the list price does. How does your model compare? 


### Task 7: Incorporating a categorical variable

Above, we considered houses, townhouses, and condos together, but here we'll distinguish between them. Consider the two regression models: 

`SoldPrice = beta_0 + beta_1 * Prop_Type_num`

and 

`SoldPrice = beta_0  + beta_1 * Prop_Type_num + beta_2 * TotSqf`

From the first model, it would appear that Property type is significant in predicting the sold price. On the other hand, the second model indicates that when you take into account total square footage, property type is no longer predictive. Explain this. (Hint: there is a confounder lurking here.) Make a scatterplot of TotSqf vs. SoldPrice where the house types are colored differently to illustrate your explanation. 