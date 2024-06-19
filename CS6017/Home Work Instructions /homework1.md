# Homework 1: Python intro and simple statistics

# Due Friday, May 24

Submit your solution as a jupyter notebook to your github repo.  If you look at your repo using the github web interface, it should render a non-interactive version of your notebook.

## Python/Numpy

1.  Write functions to compute the mean, and standard deviation of a list of data

2.  Use `scipy.stats.norm` to sample from the normal(gaussian) distribution.  Compute the mean, and standard deviation of your set of samples using your functions, and with the built in numpy methods.  Verify you get the expected results (you know what these values should be if you sample from a normal distribution).
    
3.  Plot a histogram of your samples.


## Data Exploration/Analyis

Grab a year's worth of hourly SLC PM2.5 data in CSV form from [here](http://www.airmonitoring.utah.gov/dataarchive/archpm25.htm) (at the bottom)

Pick one of the monitoring stations from the dataset and perform your analysis from the readings from that station.

Plot the readings from that station over the course of a year

You'll find that there's so much data that it's a slightly difficult to gain much insignt from this visualization.  We want to explore the variation of pollution levels over time, looking at 2 different timescales.

Plot the mean pm2.5 level for each month using a bar chart.  Note any insights you can gain from this visualization.  

Next, group the data by time of day (by hour), and plot the mean pollution level for each hour.  What insights can you draw from this view of the data?

The mean only gives us a very coarse view of the monthly/hourly data.  Use Box and Whisker plots of the monthly and hourly data groupings to provide a more complete view of the data.  Does this view provide any additional insights?

### Tips

You'll need to use the `pd.read_csv` method to load data.  There's a bunch of optional parameters you'll likely need to tweak.

You'll want to use the DataFrame `groupby` and `boxplot` methods.  

You can pass a function as a "by" parameter to extract the month or hour from a `datetime` object.

Plotting functions return a "subplot" object which you can manipulate to change some attributes of their appearance.  You can modify some others by modifying the `plt` object (assuming you `import matplotlib.pyplot as plt`) at the top of your notebook.  In my experience, tweaking the look of plots requires a lot of patience and documentation digging.
