#Image
FROM golang:1.7.1

#Author
MAINTAINER Thiago Zilli <thiago.zilli@gmail.com>

#Enviroment 
ENV USER=root
ENV DEBIAN_FRONTEND=teletype

#Upgrade and install python
RUN apt-get update && apt-get install -y --no-install-recommends python-pip apt-utils curl git

RUN pip install httpie


#Set timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Kala
RUN go get -v github.com/ajvb/kala

# Port
EXPOSE 8011

#Run App
CMD ["kala", "run", "-p", "8011"]
