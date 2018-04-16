>/root/.ssh/known_hosts
docker rm -f gitbook
if [ "$1" = "bash" ];then
docker run --name gitbook -it -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing \
	-v ~/.ssh:/root/.ssh \
	-v /home/figo/shells/docker/gitbook/startup.sh:/root/startup.sh \
	liuxing1981/gitbook sh
else
docker run --name gitbook -d -p 4000:4000 -e HTTPS_URL=https://github.com/liuxing1981/gitbook.git \
	liuxing1981/gitbook
fi
#	-v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
#	-v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
	#-v /tmp/test:/root/project \
