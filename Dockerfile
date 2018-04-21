############################################################
# Dockerfile to run a Django-based web application
# Based on an AMI
############################################################
# cd ~/src
# mkdir gunicorn_docker
# cd gunicorn_docker
# mkdir code

# Set the base image to use to Ubuntu
FROM ubuntu:14.04

MAINTAINER Hobson Lane

# Set env variables used in this Dockerfile (add a unique prefix, such as AICHAT)
# Local directory with project source
ENV AICHAT_SRC=code/aichat
# Directory in container for all project files
ENV AICHAT_SRVHOME=/srv
# Directory in container for project source files
ENV AICHAT_SRVPROJ=$AICHAT_SRVHOME/$AICHAT_SRC

# Update the default application repository sources list
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y python python-pip
RUN apt-get install -y python-dev
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y mysql-server
RUN apt-get install -y nginx

# Create application subdirectories
WORKDIR $AICHAT_SRVHOME
RUN mkdir media static logs
#read
VOLUME ["$AICHAT_SRVHOME/media/", "$AICHAT_SRVHOME/logs/"]

# Copy application source code to SRCDIR
COPY $AICHAT_SRC $AICHAT_SRVPROJ

# Install Python dependencies
RUN pip install -r $AICHAT_SRVPROJ/requirement-base.txt

# Port to expose
EXPOSE 8000

# Copy entrypoint script into the image
WORKDIR $AICHAT_SRVPROJ
COPY ./docker-entrypoint.sh /
COPY ./django_nginx.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/django_nginx.conf /etc/nginx/sites-enabled
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ENTRYPOINT ["/docker-entrypoint.sh"]