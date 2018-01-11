>/root/.ssh/known_hosts
docker rm -f gitbook
#docker run --name gitbook -it -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing -v ~/.ssh:/root/.ssh liuxing1981/gitbook sh
docker run --name gitbook -d -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub liuxing1981/gitbook
