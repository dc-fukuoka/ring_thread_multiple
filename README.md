A simple MPI ring with MPI_THREAD_MULTIPLE.  

ex, # of tasks = 2, # of threads = 2, array size = 4:  
  
```
MPI task # : 0       1  
thread #   : 0   1   0   1
array index: 1 2 3 4 1 2 3 4
```
  
task 0 thread 0 sends sendarray(1:2) to recvarray(1:2),  
task 0 thread 1 sends sendarray(3:4) to recvarray(3:4),  
task 1 thread 0 sends sendarray(1:2) to recvarray(1:2),  
task 1 thread 1 sends sendarray(3:4) to recvarray(3:4).  
  
This is just a test of MPI communication with MPI_THREAD_MULTIPLE, probably not so much effective.

```
$ make
$ mpirun -H localhost:16,r7i4n3:16 -npernode 4 -np 8 -x OMP_NUM_THREADS=4 -x PATH -x LD_LIBRARY_PATH -x PSM2_CUDA=0 ./a.out $((1024*1024))
 size:     1048576
 time[s]:   1.7100239929277450E-003
```

My note: Based on some tests, tag number should be the thread number, otherwise the result is corrupted.  
for debugging purpose(with -D_DEBUG), fort.1xx(xx is rank # of sender) should be equal to fort.2yy(yy is rank # of reciever).  
ex: np = 4 case, fort.100 must equal to fort.201, fort.101 must equal to fort.202,... fort103 must equal to fort.200.
