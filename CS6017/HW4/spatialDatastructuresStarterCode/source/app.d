import std.stdio;
import common;
import dumbknn;
import bucketknn;
import quadTree;
import kdtree;
import std.conv;
//import your files here

void main()
{
    //prepare file to write to
    File file = File("timing.csv", "a");
    file.writeln("testType,structType,kVal,nVal,dVal,distribution,time");
    writeln("STARTING TIMING EXPERIMENT");
      
    //----------------------------------------------------
    //           BucketKNN Gaussian Varying K
    //----------------------------------------------------
    int[] kVals = [5, 10, 25, 50, 100];
    int numRepsToAvg = 50;
    int numTimingReps = 1;
    int[] nVals = [1000, 2000, 5000, 10000, 11000];
    int defaultK = 25;

    foreach(k; kVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs"; 
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,bucket,"~(to!string(k)) ~",1000,2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           BucketKNN Gaussian Varying N
    //----------------------------------------------------
    foreach(n; nVals){
        writeln("n = ", n);
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs"; 
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,bucket,25,"~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           BucketKNN Gaussian Varying D
    //----------------------------------------------------
    static foreach(dim; 1..8){{
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            enum numTrainingPoints = 1000;
            auto trainingPoints = getGaussianPoints!dim(numTrainingPoints);
            auto testingPoints = getUniformPoints!dim(100);
            auto kd = BucketKNN!dim(trainingPoints, cast(int)pow(numTrainingPoints/64, 1.0/dim)); //rough estimate to get 64 points per cell on average
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, 10);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("d,bucket,25,1000,"~(to!string(dim))~",G,"~(to!string(averageTime)));    
        }
    }}
    //----------------------------------------------------
    //           BucketKNN Gaussian Varying K and N
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,bucket,"~(to!string(k))~","~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           BucketKNN UNIFORM Varying K 
    //----------------------------------------------------
    foreach(k; kVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,bucket,"~(to!string(k)) ~",1000,2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           BucketKNN UNIFORM Varying N 
    //----------------------------------------------------
    foreach(n; nVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,bucket,25,"~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           BucketKNN UNIFORM Varying D 
    //----------------------------------------------------
    static foreach(dim; 1..8){{
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            enum numTrainingPoints = 1000;
            auto trainingPoints = getUniformPoints!dim(numTrainingPoints);
            auto testingPoints = getUniformPoints!dim(100);
            auto kd = BucketKNN!dim(trainingPoints, cast(int)pow(numTrainingPoints/64, 1.0/dim)); //rough estimate to get 64 points per cell on average
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, 10);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("d,bucket,25,1000,"~(to!string(dim))~",U,"~(to!string(averageTime)));    
        }
    }}
    //----------------------------------------------------
    //           BucketKNN UNIFORM Varying K and N 
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kd = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.knnQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,bucket,"~(to!string(k))~","~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Gaussian Varying K
    //----------------------------------------------------
    foreach(k; kVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,quad,"~(to!string(k)) ~",1000,2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Gaussian Varying N
    //----------------------------------------------------
    foreach(n; nVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,quad,25,"~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Gaussian Varying K and N
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,quad,"~(to!string(k))~","~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Uniform Varying K
    //----------------------------------------------------
    foreach(k; kVals){
        writeln("k = ", k);
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,quad,"~(to!string(k)) ~",1000,2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Uniform Varying N
    //----------------------------------------------------
    foreach(n; nVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,quad,25,"~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           QuadTree Uniform Varying K and N
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto qt = QuadTree(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    qt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,quad,"~(to!string(k))~","~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }

    //----------------------------------------------------
    //           KDTree Gaussian Varying K
    //----------------------------------------------------
    foreach(k; kVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,kd,"~(to!string(k)) ~",1000,2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Gaussian Varying N
    //----------------------------------------------------
    foreach(n; nVals){
        writeln("n = ", n);
        for(int reps = 0; reps < numTimingReps; reps++){
            //will want to repeat and average
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,kd,25,"~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Gaussian Varying K and N
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;     
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,kd,"~(to!string(k))~","~(to!string(n))~",2,G,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Gaussian Varying D
    //----------------------------------------------------
    static foreach(dim; 1..8){{
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            //get points of the appropriate dimension
            enum numTrainingPoints = 1000;
            auto trainingPoints = getUniformPoints!dim(numTrainingPoints);
            auto testingPoints = getUniformPoints!dim(100);
            auto kd = KDTree!dim(trainingPoints); 
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.KNNQuery(qp, 10);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("d,kd,25,1000,"~(to!string(dim))~",G,"~(to!string(averageTime)));    
        }
    }}
    //----------------------------------------------------
    //           KDTree Uniform Varying K
    //----------------------------------------------------
    foreach(k; kVals){
        for(int reps = 0; reps < numTimingReps; reps++){
        //will want to repeat and average
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("k,kd,"~(to!string(k)) ~",1000,2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Uniform Varying N
    //----------------------------------------------------
    foreach(n; nVals){
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, defaultK);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("n,kd,25,"~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Uniform Varying K and N
    //----------------------------------------------------
    for(int index = 0; index < kVals.length; index++){
        int k = kVals[index];
        int n = nVals[index];
        for(int reps = 0; reps < numTimingReps; reps++){
        //will want to repeat and average
            long totalTime = 0;     
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto kt = KDTree!2(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kt.KNNQuery(qp, k);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";  //add the time elapsed in microseconds
            //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
            //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("kn,kd,"~(to!string(k))~","~(to!string(n))~",2,U,"~(to!string(averageTime)));
        }
    }
    //----------------------------------------------------
    //           KDTree Uniform Varying D
    //----------------------------------------------------
    static foreach(dim; 1..8){{
        for(int reps = 0; reps < numTimingReps; reps++){
            long totalTime = 0;
            //get points of the appropriate dimension
            enum numTrainingPoints = 1000;
            auto trainingPoints = getUniformPoints!dim(numTrainingPoints);
            auto testingPoints = getUniformPoints!dim(100);
            auto kd = KDTree!dim(trainingPoints); 
            auto sw = StopWatch(AutoStart.no);
            for(int round = 0; round < numRepsToAvg; round++){
                sw.start; //start my stopwatch
                foreach(const ref qp; testingPoints){
                    kd.KNNQuery(qp, 10);
                }
                sw.stop;
                totalTime+= sw.peek.total!"usecs";
            }
            long averageTime = totalTime/numRepsToAvg;
            file.writeln("d,kd,25,1000,"~(to!string(dim))~",U,"~(to!string(averageTime)));    
        }
    }}

    file.close();
    writeln("ENDING TIMING EXPERIMENT: CSV DONE!");

}