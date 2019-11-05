FROM mhart/alpine-node

#use aliyun and dns
#RUN sed -i s/dl-cdn\.alpinelinux\.org/mirrors.aliyun.com/g /etc/apk/repositories && \
RUN apk update && apk add --no-cache openssh-client git curl expect
#use no StrictHostKeyChecking
RUN sed -i '/StrictHostKey/ {s/#//;s/ask/no/}' /etc/ssh/ssh_config

WORKDIR /root
EXPOSE 4000 35729
ENV PROJECT=/root/project

#install gitbook
RUN npm install --global gitbook-cli && \
gitbook fetch && \
npm cache verify &&\
rm -rf /tmp/* && \
#install plugins
echo -e "{\n\
    \"plugins\": [\"-lunr\", \"-search\", \"search-plus\", \
	\"expandable-chapters-small\",\"splitter\",\"ace\",\"edit-link\", \ 
	\"code\",\"pageview-count\",\"alerts\",\"klipse\",\"emphasize\",\"back-to-top-button\", \
	\"flexible-alerts\"],\n\
    \"pluginsConfig\": {\n\
        \"edit-link\": {\n\
            \"base\": \"LINK_URL\",\n\
            \"label\": \"Edit This Page\"\n\
         }\n\
     }\n\
}" > book.json && \
gitbook install && \
version=$(gitbook -V | grep GitBook | awk -F: '{print $2}' | sed 's/\s//') && \
mv /root/node_modules/* /root/.gitbook/versions/${version}/node_modules/ && \
rm -rf /root/node_modules
#VOLUME /root/project
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl -fs http://localhost:4000 || exit 1
COPY startup.sh /root/startup.sh
COPY git.exp /root/git.exp
CMD [ "sh","/root/startup.sh" ]
