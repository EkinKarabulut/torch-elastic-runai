# Running Elastic Distributed Training on Run:ai

## Why Torch Elastic?

Torch Elastic is suitable for various scenarios, including: 

- **Spot instances might disappear anytime:** When using spot instances that can be taken away at any time, you want your training to continue seamlessly. Torch Elastic allows for scaling up and down without interrupting your training or requiring manual intervention.
- **Connectivity faults on the nodes:** For critical workloads that must run without interruption, losing connection to some nodes is not a risk that you can afford. 
- **Over-quota system available:** With an over-quota system, idle resources can be used temporarily and reclaimed by other teams when needed.

**Side Note:** If you are new to distributed training with PyTorch, please check out [our previous blogs](https://www.run.ai/blog/multi-node-distributed-training-on-kubernetes-with-run-ai-and-pytorch) for more information.

## The Elastic Training Flow
To illustrate how elastic training works, let’s walk through a typical scenario: 

1. **Initiating the Elastic Run:** Begin by specifying the minimum and maximum number of workers (--nnodes=MIN_SIZE:MAX_SIZE) and the number of allowed failures or membership changes (--max-restarts=NUM_ALLOWED_FAILURES_OR MEMBERSHIP_CHANGES).
2. **Handling Membership Changes or Worker Failures:** If a worker becomes unavailable due to network issues or reclaimed resources:
  - PyTorch kills and restarts the worker group to rebalance the workload.
  - It checks how many workers are still available and reranks them.
  - Loads the latest checkpoints.
  - Resumes training with the remaining nodes.
3. **Restart Conditions:** This process will continue smoothly as long as the --max-restarts value is not exceeded.

This dynamic handling ensures minimal interruption and maximizes resource utilization.

**Important Note:** The checkpoints are a crucial part of Torch Elastic. As it is stated in [Pytorch documentation](https://pytorch.org/docs/stable/elastic/run.html#important-notices); “On failures or membership changes ALL surviving workers are killed immediately. Make sure to checkpoint your progress. The frequency of checkpoints should depend on your job’s tolerance for lost work.”

## Do I Need to Change My Training Script?
No, you don’t! You can use the same training scripts. In case you are not usually checkpointing your progress, you need to start saving those. Apart from that, just add the necessary flags to torchrun. 

## Why Torch Elastic is a Game-Changer for Run:ai Users
Apart from the obvious benefits of elastic distributed training, you can leverage Run:ai’s scheduling capabilities with Torch Elastic. Consider this use case:

- In a department, you have 2 projects: project-a and project-b
- Two projects (project-a and project-b) each have 2 guaranteed GPUs and are allowed to go over-quota if resources are available.
- Project-a wants to use the whole department's resources if project-b is not using them but still runs on its guaranteed GPUs otherwise.

Elastic jobs are perfect here. Launch the job with a maximum of 4 replicas and a minimum of 2. Start training with 4 GPUs. If project-b starts using GPUs, the job stops briefly, scales down to project-a’s guaranteed quota, and resumes from the latest checkpoint without manual intervention. When project-b stops using its resources, the job scales back up to 4 replicas, accelerating training while keeping resources efficiently utilized.

## Step-by-Step Guide: Running Elastic Distributed Training on Run:ai

### Prerequisites
Before diving into the distributed training setup, ensure that you have the following prerequisites in place:

- Run:ai environment (v2.17 and later): Make sure you have access to a Run:ai environment with version 2.17 or a later release, including the CLI. Run:ai provides a comprehensive platform for managing and scaling deep learning workloads on Kubernetes.
- 4 nodes with a GPU each: For this tutorial, we will use a setup consisting of four nodes, each equipped with one GPU. However, you can scale up by adding more nodes or GPUs to suit your specific requirements.
- Image Registry (e.g., Docker Hub Account): Prepare an image registry, such as a Docker Hub account, where you can store your custom Docker images for elastic distributed training.

In this tutorial, we created a simple script and a Dockerfile. [Here](https://hub.docker.com/r/ekink/elastic_pytorch) is the Docker container that contains everything in this repository for launching a distributed elastic job.


### Launching the Distributed Training on Run:ai
To start the elastic distributed training on Run:ai, ensure that you have the correct version of the CLI (v2.17 or later). To launch a distributed PyTorch training job, use the runai submit-dist pytorch command depending on your CLI version. Here is the command to submit our job:

```
runai submit-dist pytorch --name elastic-workload --workers=3 --max-replicas 4 --min-replicas 2 -g 1 -i docker.io/ekink/elastic_pytorch
```

This command will start a distributed job, which has a maximum of 4 and minimum of 2 pods running with a single GPU on each, depending on how many resources we have.


