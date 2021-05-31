all:
#	mpif90 -g -fopenmp ring_thread_multiple.F90
	mpif90 -D_DEBUG -g -fopenmp ring_thread_multiple.F90

clean:
	rm -f a.out
