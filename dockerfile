FROM mhart/alpine-node:6

#use aliyun and dns
RUN sed -i s/dl-cdn\.alpinelinux\.org/mirrors.aliyun.com/g /etc/apk/repositories

RUN apk update && apk add --no-cache openssh-client git expect
#use no StrictHostKeyChecking
RUN sed -i '/StrictHostKey/ {s/#//;s/ask/no/}' /etc/ssh/ssh_config

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
#install plugins
RUN echo -e "{\n\
    \"plugins\": [\"-lunr\", \"-search\", \"search-plus\",\"toggle-chapters\",\"splitter\",\"ace\",\"edit-link\"],\n\
    \"pluginsConfig\": {\n\
        \"edit-link\": {\n\
            \"base\": \"GIT_HUB\",\n\
            \"label\": {\n\
                         \"en\": \"Edit This Page\"\n\
                     }\n\
         }\n\
     }\n\
}" > book.json && \
gitbook install && \
version=$(gitbook -V | grep GitBook | awk -F: '{print $2}' | sed 's/\s//') && \
mv /root/node_modules/* /root/.gitbook/versions/${version}/node_modules/ && \
rm -rf /root/node_modules
CMD [ "sh","/root/startup.sh" ]
