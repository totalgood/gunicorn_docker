############################################################
# Dockerfile to run a Django-based web application
# Based on an AMI
############################################################
# cd ~/src
# mkdir gunicorn_docker
# cd gunicorn_docker
# mkdir code

# Set the base image to use to Ubuntu
FROM ubuntu:16.04

MAINTAINER Hobson Lane

# Set env variables used in this Dockerfile (use a unique prefix, such as "AICHAT")
# Relative path to local directory with project source code files
ENV PROJECT_NAME="aichat"
ENV AICHAT_SRC="$PROJECT_NAME"
ENV AICHAT_DEPLOY="$AICHAT_SRC/deploy"
ENV CENV_NAME=$PROJECT_NAME"_cenv"
# Directory in container for all project source code files
ENV AICHAT_SRVHOME=/srv
# Directory in container for project source files
ENV AICHAT_SRVPROJ="$AICHAT_SRVHOME/$AICHAT_SRC"

# environment setup for travis.yml to configure travis_install.sh
ENV DISTRIB="conda"
ENV ENVIRONMENT_YML="$AICHAT_SRVPROJ/conda/environment.yml"

# Update the default application repository sources list
RUN apt-get update && apt-get -y upgrade && apt-get install -y python3 python3-pip python-dev
# RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y git
# RUN apt-get install -y vim
# RUN apt-get install -y mysql-server
RUN apt-get install -y nginx

# Create application subdirectories
WORKDIR $AICHAT_SRVHOME
RUN mkdir media static logs
#read
VOLUME ["$AICHAT_SRVHOME/media/", "$AICHAT_SRVHOME/logs/"]

# Copy application source code to SRCDIR
COPY $AICHAT_SRC $AICHAT_SRVPROJ
RUN $AICHAT_SRVPROJ/tests/travis_install.sh

# Install Python dependencies
# RUN pip install -r $AICHAT_SRVPROJ/requirements-base.txt

# Port to expose
EXPOSE 8000

# Copy entrypoint script into the image
WORKDIR $AICHAT_SRVPROJ
COPY $AICHAT_DEPLOY/docker-entrypoint.sh /
COPY $AICHAT_DEPLOY/django_nginx.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/django_nginx.conf /etc/nginx/sites-enabled
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ENTRYPOINT ["/docker-entrypoint.sh"]