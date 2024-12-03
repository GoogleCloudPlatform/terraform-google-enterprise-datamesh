FROM python:slim

ENV CONFIDENTIAL_DATA_VIEWER_GROUP=
ENV NON_CONFIDENTIAL_DATA_VIEWER_GROUP=
ENV NON_CONFIDENTIAL_ENCRYPTED_DATA_VIEWER_GROUP=
ENV NON_CONFIDENTIAL_MASKED_DATA_VIEWER_GROUP=
ENV NON_CONFIDENTIAL_FINE_GRAINED_DATA_VIEWER_GROUP=

WORKDIR /code
COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app /code/app

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
