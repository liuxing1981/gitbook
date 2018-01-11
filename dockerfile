FROM mhart/alpine-node:6

#use aliyun and dns
RUN sed -i s/dl-cdn\.alpinelinux\.org/mirrors.aliyun.com/g /etc/apk/repositories && echo "nameserver 114.114.114.114">/etc/resolv.conf

RUN apk update && apk add --no-cache openssh-client git expect

ENV PROJECT=/root/project
ADD startup.sh /root/startup.sh
RUN chmod 755 /root/startup.sh

#install gitbook
RUN npm install --global gitbook-cli
RUN gitbook fetch
RUN npm cache clear &&\
    rm -rf /tmp/*
WORKDIR /root
EXPOSE 4000 35729
#VOLUME /root/project
CMD [ "sh","/root/startup.sh" ]
