program main
  use omp_lib
  ! use mpi_f08
  ! use mpi
  implicit none
  include "mpif.h"  
  integer :: iam, np, ierr
!$  integer :: iam_th, nth
  !  type(mpi_status) :: stat
  integer :: istart,iend,mysize,iam_g
  integer :: stat(mpi_status_size)
  integer :: sendto,recvfrom
  integer :: i,ireq,iprov
  real(8),allocatable,dimension(:) :: sbuf,rbuf
  real(8) :: t0, time
  character(len=32) :: argv1
  integer :: size
  integer :: tag1, tag2

  ireq = mpi_thread_multiple
  call mpi_init_thread(ireq,iprov,ierr)
  if (iprov .ne. ireq) then
     write(6, *) "MPI_THREAD_MULTIPLE is not supported."
     call mpi_finalize(ierr)
  end if
  call mpi_comm_rank(mpi_comm_world, iam, ierr)
  call mpi_comm_size(mpi_comm_world, np,  ierr)

  sendto = iam + 1
  if (iam .eq. np-1) sendto = 0
  recvfrom = iam - 1
  if (iam .eq. 0) recvfrom = np - 1

!  write(6, *) "sendto:",sendto,"recvfrom:",recvfrom

  if (command_argument_count() == 0) then
     size = 1024
  else
     call get_command_argument(1, argv1)
     read(argv1, *) size
  end if

  if (iam == 0) write(6, *) "size:", size
  
  allocate(sbuf(size),rbuf(size))

  !$omp parallel do default(shared) private(i)
  do i = 1, size
     sbuf(i) = 10.0d0*i + iam
     rbuf(i) = 0.0d0
  end do

  call mpi_barrier(mpi_comm_world, ierr)
  t0 = mpi_wtime()
  !$omp parallel default(shared) private(iam_th,iam_g,mysize,istart,iend,tag1,tag2,ierr)
#ifdef _OPENMP
  iam_th = omp_get_thread_num()
  nth    = omp_get_num_threads()
  iam_g  = nth*iam + iam_th
  mysize = size/nth
  istart = 1 + iam_th*mysize
  iend   = mysize*(iam_th + 1)
  tag1   = 100*iam + iam_th
  tag2   = 100*recvfrom + iam_th
#ifdef _DEBUG
  write(6,'(8(a,i4))') "iam_g: ", iam_g, " iam: ", iam, " iam_th: ",iam_th," istart: ",istart," iend: ",iend," mysize: ",mysize, &
       " tag1: ",tag1," tag2: ",tag2
#endif
#else
  mysize = size/np
  istart = 1 + iam*mysize
  iend   = mysize*(iam + 1)
!  write(6,*) "iam:",iam,"istart:",istart,"iend:",iend,"mydev:",mydev
#endif
  if (iam .eq. 0) then
     call mpi_send(sbuf(istart), mysize, mpi_real8, sendto,   tag1, mpi_comm_world, ierr)
     call mpi_recv(rbuf(istart), mysize, mpi_real8, recvfrom, tag2, mpi_comm_world, stat, ierr)
  else
     call mpi_recv(rbuf(istart), mysize, mpi_real8, recvfrom, tag2, mpi_comm_world, stat, ierr)
     call mpi_send(sbuf(istart), mysize, mpi_real8, sendto,   tag1, mpi_comm_world, ierr)
  end if
  !$omp end parallel
  call mpi_barrier(mpi_comm_world, ierr)
  time = mpi_wtime() - t0

#ifdef _DEBUG
  do i = 1, size
     write(100+iam, '(1pe14.5)') sbuf(i)
     write(200+iam, '(1pe14.5)') rbuf(i)
  end do
#endif
  
  if (iam == 0) write(6, *) "time[s]:", time
  
  deallocate(sbuf,rbuf)
  call mpi_finalize(ierr)
  stop
end program main
