# ----- Dockerfile ------
FROM python:3.11.9-slim

RUN apt-get update 

# Setup env vars 
ENV APP_HOME /app
WORKDIR $APP_HOME

# Install dependencies
RUN pip3 install google-cloud-storage
RUN pip3 install google-cloud-datacatalog
RUN pip3 install google-cloud-bigquery
RUN pip3 install google-cloud-logging
RUN pip3 install pytz
RUN pip3 install google-auth-oauthlib
RUN pip3 install google-auth

COPY Service.py $APP_HOME
CMD ["python", "Service.py"]