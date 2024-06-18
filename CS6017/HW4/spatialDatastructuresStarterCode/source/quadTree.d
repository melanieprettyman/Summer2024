import common;

struct QuadTree{
    alias P2 = Point!2; //2D Point struct
    Node root;

    //Constructor
        // takes an array of points (P2[] points) 
        // compute the bounding box (contains all the points).
        // Root is defined by the bounding box and filled with our points
    this(P2[] points){
        AABB!2 box = boundingBox!2(points);
        root = new Node(points, box);

    }

    class Node{
        bool isLeaf = false;
        P2[] nodePoints;
        AABB!2 box;
        Node[] children;
        int maxPoints = 4;
        
        //Constructor 
            //Determines whether a node should be a leaf or if it should recursively subdivide its space 
            //into four quadrants (child nodes)    
        this(P2[] points, AABB!2 bounding){

            //if the number of points in the node is less than or equal to 4, bc a leaf node 
            if(points.length <= maxPoints){
                isLeaf = true;
                nodePoints = points;
                box = bounding;
            }else{//Divide box into 4 sub boxes 
                isLeaf = false;
                //Calculate Midpoints
                float xHalf = (bounding.min[0] + bounding.max[0])/2;
                float yHalf = (bounding.min[1] + bounding.max[1])/2;

                //Partition Points into Quadrants
                //Right and Left Partitions
                P2[] rightHalf = partitionByDimension!(0, 2)(points, xHalf);
                P2[] leftHalf = points[0 .. $  - rightHalf.length];

                //Upper and Lower Partitions for both Right and Left halves
                P2[] upperRight = partitionByDimension!(1,2)(rightHalf, yHalf);
                P2[] lowerRight = rightHalf[0 .. $ - upperRight.length];
                P2[] upperLeft = partitionByDimension!(1, 2)(leftHalf, yHalf);
                P2[] lowerLeft = leftHalf[0 .. $ - upperLeft.length];


                P2 midPoint = P2([xHalf, yHalf]);
                P2 midLeftPt = P2([bounding.min[0], yHalf]);
                P2 midUpperPt = P2([xHalf, bounding.max[1]]);
                P2 upperRightPt = P2([bounding.max[0], bounding.max[1]]);
                P2 bottomLeftPt = P2([bounding.min[0], bounding.min[1]]);
                P2 lowerMidPt = P2([xHalf, bounding.min[1]]);
                P2 midRightPt = P2([bounding.max[0], yHalf]); 
                

                //Bounding Boxes for each quadrant
                AABB!2 upperRightBox = boundingBox!2([midPoint, upperRightPt]);
                AABB!2 lowerRightBox = boundingBox!2([lowerMidPt, midRightPt]);
                AABB!2 upperLeftBox = boundingBox!2([midLeftPt, midUpperPt]);
                AABB!2 lowerLeftBox = boundingBox!2([bottomLeftPt, midPoint]);

                //recursively calling Node constructor
                children ~= new Node(upperRight, upperRightBox);
                children ~= new Node(lowerRight, lowerRightBox);
                children ~= new Node(upperLeft, upperLeftBox);
                children ~= new Node(lowerLeft, lowerLeftBox);
                
            }
        }
    }

    //Find all points within a given radius of a specified point.
    P2[] rangeQuery( P2 point, float radius ){
        
        P2[] range;
        
        //If leaf node, for each point p, checks if the distance from p to the given point 
        //is less than or equal to radius. If true, the point is added to the result array 
        void recurse(Node n){
            if(n.isLeaf){
                foreach(P2 p; n.nodePoints){
                    if(distance(p, point) <= radius){
                        range ~= p;
                    }
                }
            }else{
                //check each child node and recurse
                foreach(Node child; n.children){
                    P2 closestPoint = closest!2(child.box, point);
                    if(distance(closestPoint, point) <= radius){
                        recurse(child);
                    }
                }
            }
        }
        recurse( root );
        return range;
        
    }

    //KNNQuery 
    //Takes a point and an integer K, indicating the number of closest points to find.
    //Init a priority queue that stores the points, sorted by their distance from point.
    //Returns an array of points that represent the K nearest neighbors to the given point.
    P2[] KNNQuery( P2 point, int K){
        auto priorityQueue = makePriorityQueue!2(point);
            void recurse(Node n){
                //base case; node is a lead node--loop through all points in the node 
                if(n.isLeaf){
                    foreach(P2 p; n.nodePoints){
                        //If the priority queue is not full, inserts the point
                        if(priorityQueue.length < K){
                            priorityQueue.insert(p);
                        //if our priority queue is full, check if this point is closer than the farthest point
                        }else if(distance(p, point) < distance(priorityQueue.front, point)){
                            priorityQueue.popFront;
                            priorityQueue.insert(p);
                        }
                    }
                }else{
                    foreach(Node child; n.children){
                    P2 closestPoint = closest!2(child.box, point);
                        // If the priority queue is not full  or the closest point in child is closer than 
                        //the farthest point in the queue to point recurses into the child
                        if(priorityQueue.length < K || (distance(closestPoint, point) < (distance(priorityQueue.front, point)))){
                            recurse(child);
                        }
                    }
                }
            }
        recurse( root );
        return priorityQueue.release;
    }

}


unittest{
    auto points = [Point!2([.5, .5]), Point!2([1, 1]),
                   Point!2([0.75, 0.4]), Point!2([0.4, 0.74])];

    auto qt = QuadTree(points);

    //checks that exactly 3 points are within this radius
    foreach(p; qt.rangeQuery(Point!2([1,1]), .7)){
        writeln(p);
    }
    assert(qt.rangeQuery(Point!2([1,1]), .7).length == 3);

    foreach(p; qt.KNNQuery(Point!2([1,1]), 3)){
        writeln(p);
    }
}

unittest{
    auto points = [Point!2([0,0]), Point!2([2.5,0]), Point!2([5,0]), Point!2([7.5,0]), Point!2([10,0]),
                   Point!2([0,2.5]), Point!2([2.5,2.5]), Point!2([5, 2.5]) ,Point!2([7.5,2.5]), Point!2([10, 2.5]),
                   Point!2([0,5]), Point!2([2.5,5]), Point!2([5, 5]) ,Point!2([7.5, 5]), Point!2([10, 5]),
                   Point!2([0,7.5]), Point!2([2.5,7.5]), Point!2([5, 7.5]) ,Point!2([7.5, 7.5]), Point!2([10, 7.5]),
                   Point!2([0, 10]), Point!2([2.5, 10]), Point!2([5, 10]) ,Point!2([7.5, 10]), Point!2([10, 10])];

    auto qt = QuadTree(points);
    auto pointsInRadius = qt.rangeQuery(Point!2([3, 3]), 3);
    
}

