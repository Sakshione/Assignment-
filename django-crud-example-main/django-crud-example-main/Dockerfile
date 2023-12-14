FROM ubuntu
# Set the working directory inside the container
WORKDIR /app
# Copy requirements and application code
COPY requirements.txt .
COPY . /app/
#COPY .env /app/
RUN chmod 766 -R /app/
# Install Python and dependencies
RUN apt-get update && apt-get install -y python3 python3-pip
