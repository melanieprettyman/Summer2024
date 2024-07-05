# Homework 5: Classifiers

Adapted from COMP 5360 / MATH 4100, University of Utah, http://datasciencecourse.net/

Due: Tuesday, July 9

In this homework, you will use classification methods to classify handwritten digits (Part 1) and predict the popularity of online news (Part 2). We hope these exercises will give you an idea of the broad usage of classification methods. 

## Part 1: MNIST handwritten digits

THE MNIST handwritten digit dataset consists of images of handwritten digits, together with labels indicating which digit is in each image. You will see that images are just matrices with scalar values, and that we can use all the classifcation algorithms we studied on them.  We saw these in class when we looked at clustering methods.

Because both the features and the labels are present in this dataset (and labels for large datasets are generally difficult/expensive to obtain), this dataset is frequently used as a benchmark to compare various classification methods. 
For example, [this webpage](http://yann.lecun.com/exdb/mnist/) gives a comparison of a variety of different classification methods on MNIST (Note that the tests on this website are for higher resolution images than we'll use.) 

In this assignment, we'll use scikit-learn to compare classification methods on the MNIST dataset. 

There are several versions of the MNIST dataset. We'll use the one that is built-into scikit-learn, described [here](http://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_digits.html).  You can easily use this in your assignment by using the `load_digits` method: `from sklearn.datasets import load_digits`

Here's a summary of the dataset:

* Classes: 10 (one for each digit)
* Samples total: 1797
* Samples per class: about 180
* Dimensionality: 64 (8 pixels by 8 pixels)
* Features: integers 0-16 (grayscale value; 0 is white, 16 is black)

Start by loading the data set and then scaling it using the `sklearn.preprocessing.scale` method so that the mean entries are `0` and the variances are `1`.  You can read details about scaling and why it's important [here](http://scikit-learn.org/stable/modules/preprocessing.html#standardization-or-mean-removal-and-variance-scaling).


Plot a few of the sample images using the `imshow` method to see what you're working with.

### Classification

Use sklearn's `train_test_split` method to divide the data into training and testing sets

#### SVM

* Use SVM with an `rbf` kernel and parameter `C=100` to build a classifier using the *training dataset*.
* Using the *test dataset*, evaluate the accuracy of the model. Again using the *test dataset*, compute the confusion matrix. What is the most common mistake that the classifier makes? 
* Plot all of these misclassified digits as images. 
* Using the 'cross_val_score' function, evaluate the accuracy of the SVM for 100 different values of the parameter C between 1 and 500. What is the best value? 
* Try to train and test the algorithm on the raw (non-scaled) data. What's your accuracy score?

#### KNN

Repeat the same experiments as you did with the SVM.  Start with a `k` of 10 for the first experiment and then try to find a good value of `k` using `cross_val_score`

## Part 2: Online News Dataset

For this part of the assignment, you will use classification tools to predict the popularity of online news based on attributes such as the length of the article, the number of images, the day of the week that the article was published, and some variables related to the content of the article. You can learn details about the datasetat the
[UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/Online+News+Popularity). 
This dataset was first used in the following conference paper: 

K. Fernandes, P. Vinagre and P. Cortez. A Proactive Intelligent Decision Support System for Predicting the Popularity of Online News. *Proceedings of the 17th EPIA 2015 - Portuguese Conference on Artificial Intelligence* (2015).

The dataset contains variables describing 39,644 articles published between January 7, 2013 and Januyary 7, 2015 on the news website, [Mashable](http://mashable.com/). 

There are 61 variables associated with each article. Of these, 58 are *predictor* variables, 2 are variables that we will not use (url and timedelta), and finally the number of shares of each article. The number of shares is what we will use to define whether or not the article was *popular*, which is what we will try to predict. You should read about the predictor variables in the file *OnlineNewsPopularity.names*. Further details about the collection and processing of the articles can be found in the conference paper. 


### Import the data 

* Use the pandas.read_csv() function to import the dataset.
* To use [scikit-learn](http://scikit-learn.org), we'll need to save the data as a numpy array. Use the `DataFrame.values()` method to export the predictor variables as a numpy array.  This array should not include our target variable (the number of shares). We don't need the url and timedelta, so drop those columns. 
* Export the number of shares as a separate numpy array. We'll define an article to be popular if it received more shares than the median number of shares. Create a binary numpy array, which indicates whether or not each article is popular.

### Exploratory data analysis 

First check to see if the values are reasonable. What are the min, median, and maximum number of shares? 

### Classification using KNN

Develop a KNN classification model for the data. Use cross validation to choose the best value of k. What is the best accuracy you can obtain on the test data? 

### Classification using SVM

Develop a support vector machine classification model for the data. 
 
 * SVM is computationally expensive, so start by using only a fraction of the data, say 5,000 articles. 
 * Experiment with different Cs. Which is the best value for C?

Note that it may take multiple minutes per value of C to run on the whole dataset!

### Classification using decision trees

Develop a decision tree classification model for the data. 

Use cross validation to choose good values of the max tree depth (`max_depth`) and minimum samples split (`min_samples_split`). 

### Describe your findings
* Which method (k-NN, SVM, Decision Tree) worked best?
* How did different parameters influence the accuracy?
* Which model is easiest to interpret?
* How would you interpret your results?
