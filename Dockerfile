FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

RUN pip install torch

# Set the working directory 
WORKDIR /app

# Copy the current directory contents into the container at /app 
COPY distributed.py launch.sh /app/

# Run the bash file
RUN chmod u+x launch.sh
CMD ["./launch.sh"]

