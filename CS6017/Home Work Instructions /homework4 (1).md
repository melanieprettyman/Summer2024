# Homework 4: Implementing + Evaluating Spatial Partitioning Data Structures

## Due Friday, June 21 (2 weeks because it's bigger!)

In this assignment you'll implement and compare the performance of the 3 spatial partitioning data structures we've discussed in class: bucketing, KD-trees, and QuadTrees

## Part 1: Implementation

I've provided implementations of 2 data structures: a "dumbknn" which just stores a list of points and loops through all of them to do queries, and a uniform-grid based data structure which I called "bucketknn."  

Implement the 2 tree data structures (quadtree and KD tree)

Each of these should have an appropriate constructor, rangeQuery(p, r), and KNN(p, k) methods.

I've provided a project skeleton that uses the [D programming language](https://dlang.org).  [Download it from here](spatialDatastructuresStarterCode.zip).  In addition to the 2 data structures, it contains the file common.d which has a Point struct with overloaded operators, and a bunch of helper functions. **My goal is that you use the functions/structs in that file so that your actual source code looks very similar to the pseudocode we discuss in class.**  I've also put in some basic timing/testing code in app.d. 

### Part 1.1: Read the provided code

Read the 4 provided D files and familiarize yourself with what it does/how it works.  Pay special attention to common.d which contains a lot of stuff you'll need to use.  In the description below there's a quick guide to D that should help make sense of some unfamiliar syntax stuff (what the heck is a `!` doing there?, etc).  Read through that before you start looking too closely at the code.

The `unittest{}` blocks contain ... unittests.  These are a great tool for understanding unfamiliar code since they show you how to actually use the API.  Pay special attention to these!

### Part 1.2: Actually implement the 2 tree data structures.

Because we're interested in timing these data structures, we're using a native-compiled language (sorry Python, Java).  In years past, we've used C++ but the code is a bit tricky and very ugly.  I think you'll enjoy working with D (it's my favorite language) and hopefully it makes your life easier.  If you're eager to use the C++ version, I'll provide skeleton C++ code that you can use to start.

There are a couple of different ways you'll want to "run" your code that will make use of the `dub` command which is a build/runner tool for the d language.  To install the tools you need, run `brew install ldc dub` which will install the LLVM based D compiler ldc (the `ldc2` program) and the `dub` build tool.  You'll use `dub` to run the compiler for you, so you shouldn't have to actually run `ldc` yourself.  

* `dub test` -- this runs all the code inside of `unittest{ }` blocks in the whole project.  I suggest adding at least one per file.  I tend to use a mix of `assert()` for automated unittesting along with `writeln` to run some code and print stuff that I can check manually.  There are examples of `unittest` blocks in `common.d` and `dumbknn.d`.
* `dub run` -- this runs the `main` function in `app.d`.  This will build/run your program in debug mode.  This will tradeoff compiler speed/debugability for runtime speed.  I use this command as I'm building to get quick turnaround time.
* `dub run --build=release` -- This turns on optimizations to make really fast code.  Use this to get good timing information.  

### Implementation notes



#### D stuff

To get answers from the internet about google, you usally want to search for "dlang" (I assume you can guess why).

VSCode has a plugin for working with D code (search for dlang and install the package from `WebFreak`).  It includes syntax highlighting and I think also autocompletion + debugger support (though I haven't used those).  I think you can use VSCode's play button to run code with it installed, but I generally just use the `dub` commands above from the VSCode terminal.

For the most part, the D syntax looks like C++/Java.  One new thing is "compile-time parameters" which are very similar to templates in C++ or Generics in Java, but which are a lot nicer to work with.

**You might want to have the code in app.d, dumbknn.d, and common.d open while reading through this section.  The stuff below will probably make more sense if you see it used in example code.**

Your file names should be lowercase and end with `.d`.  To use classes/structs/functions from another file, use `import filename`, but drop the `.d`.  There's no "header files" or anything like that, so just write your code like you would in Java.  You can have as many structs/functions in a file as you want and their names don't need to match the filename.  See how app.d imports the data structures, and the knn files import common to access Point structs and other stuff.

In D, if a function takes 0 parameters, you can leave off the `()` when you call it if you want.  I think I do this sometimes in the skeleton code.  Common "D style" is to add the parentheses when the function "does a lot of work" as a hint to the reader, and to omit them for things like "getters."  

In D, `x.f(a, b, c)` is basically equivalent to `f(x, a, b, c)` (this is called "universal function call syntax", or UFCS in D parlance).  Many places in the example code it looks like I'm calling a method, but I'm actually calling a normal function.  Again, this doesn't really matter, use whichever version "feels" better as appropriate.

A struct (or function) can optionally have "compile time parameters" which must be specified at compile time.  The `Point` struct in `common.d` and the `DumbKNN` struct make use of these.  When you're defining a struct, any compile time parameters go in parentheses between the struct name and the opening `{` of the struct body.  When you're using the struct, the compile time parameters go after a `!` in parentheses.  If the parameters is a single "token" you skip the parentheses.  For example, `Point!2` and `Point!(2)` are how I could refer to a 2D Point struct.  The reason we use these is because we want to have arrays with compile-time known size, so we can store them directly in an object, rather than storing a pointer to them somewhere else on the heap.

All functions have runtime parameters (the normal function parameters we have in every language), but in D they can also have compile time parameters.  When defining a function with compile time parameters, they're listed in parentheses before the runtime parentheses.  Like with structs, when you need to pass these parameters when calling those functions, you put the compile time arguments after a `!` and then put the run-time parameters in parentheses as usual.  There is one place where it will be helpful for you to write a function making use of these, which I'll comment on later.  The unittest blocks show examples of calling functions that take compile time parameters.  Note: usually the compiler can "infer" what these should be and you don't necessarily need to specify them yourself with a `!`.

We'll make use of D's dynamic arrays which are sort of an in-between of C++ vectors, and python lists.  You can append to them with the `~` operator.  They have a `.length` property, and in `[]` expressions, you can use `$` to refer to the length: `last3Elements = someArr[$-3 .. $]`

You can try stuff out in this [online playground](https://run.dlang.io). Please ask D questions publicly on Slack too!

#### Overview

The `DumbKNN` file gives you an overview of what your data structures will look like.  You'll need to make a struct with the Dimension as a compile time parameter.  We need this so that the compiler knows how big a Point struct is and can lay them out next to each other in memory.

Each data structure will be a struct (with the Dimension as a compile-time parameter, except for quadtrees which only work in 2D).  In each struct you'll need:

* Member variables (I'll list suggestions for each data structure below)
* A constructor -- in D constructors don't have a return type and are named `this()`.  All of your constructors will take an array of points, which you'll spell like `Point!Dim[]` assuming your struct's compile-time parameter is named `Dim`.
* `Point!Dim[] rangeQuery(Point!Dim p, float r)` -- return all points within a distance `r` of `p`
* `Point!Dim[] knnQuery(Point!Dim p, int k)` -- return the `k` points closest to `p`

#### Bucket KNN (provided)

This data structure splits space into buckets.  Each bucket just stores a list of points that are within the same "rectangle" of space.  mine is implemented as a "dense" array, but it's possible to use "spatial hashing" and basically store buckets in a hash table. 

To perform queries, determine which "buckets" are of interest, and then loop through all the points in those buckets.

Your data structures will be quite a bit different since they're tree based, but it's worth reading through this struct to get a feel for D and how to work with the point struct, etc.

#### QuadTree

One way in which this is simpler than the KD tree is that it only works in 2D.  I added `alias P2 = Point!2` at the top of my struct for convenience (then use `P2` as your point type in the rest of the implementation).

Because this is a tree data structure, I suggest defining an internal `Node` class.  In D, `class` objects are created with the `new` keyword and go on the garbage collected heap (just like in Java.  `struct` objects go on the stack).  Your node class will store:

* A list of points (if it's a leaf node)
* 4 children (if it's an internal node).  Note, some of the children might be null.
* An AABB that explains what area this node covers

It's probably easiest to have fields for all possible things you want to store in a node and have a boolean to tell you whether or not it's a leaf.

The Quadtree struct can then just store a `Node root`.

The Node constructor should take a list of points, and an AABB describing what area it covers.  It will recursively call itself when constructing children (if necessary).  You'll probably want to use the `partitionByDimension` method from `common.d` here.

For the query methods, I recommend defining a nested function for recursion:

```
P2[] rangeQuery(P2 p, float r){
  P2[] ret;
  void recurse(Node n){
    decide how to add stuff to ret, and recurse
    You can access variables defined in rangeQuery here
    (eg, use p, r, and append to ret)
  }
  recurse(root);
  return ret;
}
```

Using nested functions is D is handy because it's "extra private" (ie you can't refer to it outside of the enclosing function) and it can access the variables defined above it in the enclosing function.

For the KNNQuery method, you'll do something similar, but we'll need to use a priority queue to keep track of the results.  See the `makePriorityQueue` and associated unittest in `common.d` for usage.


#### KDTree

This is similar to the quadtree except that the Node class should take a compile-time `int` parameter specifying which dimension it "split's" on (does it split points based on point[0] (the x-coordinate), point[1] (the y-coordinate), point[2](the z-coordinate), etc).  Using a compile-time parameter here saves memory (it doesn't need to be stored at runtime), and it can make sure we catch bugs related to using the wrong type of node at compile time.

Here's some code snippets that might help with the tricky bits:

```
//An x-split node and a y-split node are different types
class Node(size_t splitDimension){
 //if this is an x node, the next level is "y"
 //if this is a y node, the next level is "z", etc
  enum thisLevel = splitDimension //this lets you refer to a node's split level with theNode.thisLevel
  enum nextLevel = (splitDimension + 1) % Dim 
  Node!nextLevel left, right;//child nodes split by the next level

}
```

In this context `enum` is used to refer to constants that don't need to be stored in memory at runtime.

Like the QuadTree, I suggest using a nested `recurse` function, but now because the node types are different, it needs to take a compile time parameter as well:

```
P2[] rangeQuery(P2 p, float r){
  P2[] ret;
  void recurse(NodeType)(NodeType n){
    decide how to add stuff to ret, and recurse
    You can access variables defined in rangeQuery here
    (eg, use p, r, and append to ret)
    ...
    recurse(n.left); //this will work.
  }
  recurse(root);
  return ret;
}
```

The compile time parameter will be automatically inferred, so you don't need to specify it after a `!`.


## Part 2: Testing/Timing

We want to know how our KNN performance is affected by:

* k
* N (the total number of points)
* D (the dimension of your data.  Quadtrees will only work for D=2)

(we'll just test the KNN queries, not the range queries).

You may also want to play with different approaches for choosing the number of bucket divisions (for bucketing), or the maximum leaf size (for your quadtree).  This is optional, but pick something reasonable for these parameters (play around a little bit and pick the best option you find).

Your testing code should create a CSV file that contains all the necessary data to load into a DataFrame in a Jupyter notebook.

Perform your tests for uniformly distributed data points, and gaussian distributed data points (which will clump them around the mean)

To reduce noise, I recommend timing several KNN queries (10, or 100) and using the average time.  Repeating each experiment 3 times or so (with different random points) should also help you feel more confident about your results.  You can also include each trial in your CSV output (you'd have multiple rows with the same K, N, D, but different timings, for example).

Produce a data set where you vary one of k, N, or D at a time, so you'll get basically 3 data sets, one where you fix k, and N, but vary D, one where you fix D and N, but vary k, and one where you vary N only.

Produce one data set where D is fixed to be 2, but vary both k and N by picking 5-10 values of each, and timing all combinations.

We want to get a pretty big set of timing data to play with without going too overboard, so try aim for having your suite of timing tests take 1-2 minutes to run in total.  


## Part 3: Analysis

Analyze the data you collected.  

* Plot parts of your data to make sense of it(what impact to K, N, D, and the data structure have?)
* Perform regression based on the performance we expect to see.  Do tests confirm or disprove our expectations?  What running times do you expect to see based on simple big-O analysis?
* Are there any aspects of your data that seem unusual?  Can you explain them?

This is pretty open ended.  The goal is to use simple visualization and regression to make sense of the timing data that you collected.




