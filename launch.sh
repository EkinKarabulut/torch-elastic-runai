#!/bin/bash

master_addr=$MASTER_ADDR
master_port=$MASTER_PORT
job_n=$WORLD_SIZE
#job_id=$RANK

# Echo these if needed
#echo ${job_n}
#echo ${job_id}
#echo ${master_addr}
#echo ${master_port}

LOGLEVEL="INFO" torchrun --nproc_per_node=1 --nnodes=2:${job_n} --max-restarts=3 --rdzv_endpoint=${master_addr}:${master_port} --rdzv_backend=c10d distributed.py --batch_size 8 1000 2
