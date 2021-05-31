A simple MPI ring with MPI_THREAD_MULTIPLE.  

ex, # of tasks = 2, # of threads = 2:  
  
```
MPI task # : 0       1  
thread #   : 0   1   2   3  
array index: 1 2 3 4 5 6 7 8
```
  
task 0 thread 0 send sendarray(1:2) to recvarray(1:2),  
task 0 thread 1 send sendarray(3:4) to recvarray(3:4),  
...  
