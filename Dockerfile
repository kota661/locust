FROM python:3.6.6-alpine3.8

RUN apk --no-cache add g++ \ 
      && apk --no-cache add zeromq-dev \
      && pip install locustio pyzmq

ADD locust_files /locust_files

EXPOSE 8089 5557 5558

ENTRYPOINT ["/usr/local/bin/locust"]
