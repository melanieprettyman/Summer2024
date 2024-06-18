import common;

struct KDTree(size_t dim){
    alias Pt = Point!dim;
    Node!0 root;

    //constructor initializes the tree with a list of points, 
    //and creates the root node starting with 0th dimension as the splitting dimension
    this(Pt[] points){
        root = new Node!0(points);
    }

    class Node(size_t splitDim){
        enum currentLevel = splitDim;
        enum nextLevel = (splitDim +1 ) % dim;
        public Node!nextLevel leftChild, rightChild;
        public Pt splitPoint;

        this(Pt[] points){
        
            //Base Case: If the list of points contains only one point, it becomes the splitPoint 
            //and the node will have no children.
            if(points.length == 1){
                splitPoint = points[0];
            }else{
                //sorts points by the specified dimension, leftHalf is the first half of the sorted list, 
                //including the median point.
                Pt[] leftHalf = medianByDimension!(currentLevel, dim)(points);
                splitPoint = points[leftHalf.length];
                //left half pts are used to recursively create the left child node at the next dimension level 
                leftChild = new Node!nextLevel(leftHalf);
                // If there are more than two points, the remaining right half points are used to create the right child node
                if (points.length > 2){
                    rightChild = new Node!nextLevel(points[leftHalf.length + 1 .. $]);
                }
            }
            
        }
    }

    Pt[] rangeQuery( Pt p, float r ){
        Pt[] range;

        void recurse( NodeType )( NodeType n ){
            //Distance Check: 
            //If the distance from p to the splitPoint of node n is less than or equal to radius r, n.splitPoint to the results
            if (distance(p, n.splitPoint) <= r){
                range ~= n.splitPoint;
            }
            //Rurse Left:
            //If the node has a left child and the dimensionally adjusted coordinate of p minus r 
            //is less than or equal to the corresponding coordinate of the left child’s splitPoint
            if(n.leftChild !is null && p[n.nextLevel] - r <= n.leftChild.splitPoint[n.nextLevel]){
                recurse(n.leftChild);
            }
            //Rurse Right:
            if(n.rightChild !is null && p[n.nextLevel] + r >= n.rightChild.splitPoint[n.nextLevel]){
                recurse(n.rightChild);
            }
        }   
        
        recurse( root );
    return range;
    }


// K-nearest neighbors search, finding the K closest points to a specified point within the k-dimensional space
    Pt[] KNNQuery( Pt point, int K){
        auto priorityQueue = makePriorityQueue!dim(point);
        //bounding box, bbox, starts with infinite bounds, which will gradually narrow as the tree is traversed
        AABB!dim bbox;
        bbox.min[] = -float.infinity;
        bbox.max[] = float.infinity;

        void recurse(NodeType)(NodeType n, AABB!dim tempBox){
            //If the priorityQueue is not yet full, the split point is directly added
            if(priorityQueue.length < K){
                priorityQueue.insert(n.splitPoint);
            }
            //If the priorityQueue is full and the split point is closer than the farthest point in the priorityQueue
            //the farthest point is removed, and the new point is inserted.
            else if(distance(n.splitPoint, point) < distance(priorityQueue.front, point)){
                priorityQueue.insert(n.splitPoint);
                priorityQueue.popFront;
            }

            //Init Left bounding box with current box
            AABB!dim leftbbox = tempBox;
            //Max boundary for the current dimension is set to the node’s splitPoint
            leftbbox.max[n.currentLevel] = n.splitPoint[n.currentLevel];

            AABB!dim rightbbox = tempBox;
            rightbbox.min[n.currentLevel] = n.splitPoint[n.currentLevel];

            // Recurse children nodes;
            // First check if there is a child and that the priorityQueue isn't full
            //If the closest point of the b-box to point is closer than the farthest point, recurse 
            if(n.leftChild !is null && (priorityQueue.length < K ||  
            distance(closest(leftbbox, point), point) < distance(priorityQueue.front, point)))
            {
                recurse(n.leftChild, leftbbox);
            }
            if(n.rightChild !is null && (priorityQueue.length < K || 
            distance(closest(rightbbox, point), point) < distance(priorityQueue.front, point)))
            {
                recurse(n.rightChild, rightbbox);
            }
        }
        recurse( root, bbox );
        return priorityQueue.release;
    }
}


unittest{
    auto points = [Point!2([0,0]), Point!2([1, 1]), Point!2([2,2])];
    auto testKDTree = KDTree!2(points);
    assert(testKDTree.rangeQuery(Point!2([2,3]), 5.0).length == 3);
}

alias Pt = Point!2;
unittest{
    auto kdtree = KDTree!2([Pt([0, 1]), Pt([0, 2]), Pt([0, 3]), Pt([0, 4]), Pt([0, 5])]);
    auto nearest_neighbor2D = kdtree.KNNQuery(Pt([0, 0]), 1);
    auto nearest_neighbors2D = kdtree.KNNQuery(Pt([0, 0]), 2);

    assert(nearest_neighbor2D.length == 1);
    assert(nearest_neighbor2D[0] == Pt([0, 1]));
    assert(nearest_neighbors2D.length == 2);
    assert(nearest_neighbors2D[0] == Pt([0, 2]));
}

