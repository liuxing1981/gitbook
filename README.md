# 用法

可以把任何的git工程加上一个gitbook的文件夹，这个文件夹作为gitbook服务器显示的内容
这些markdown文件可以是这个git工程的说明文档，客户需求等等。
运行方式有两种：

#### 第一种

```
docker run -d -p 4000:4000 -v yourPath:/root/project liuxing1981/gitbook
```
##### gitbook的默认用法，把本地文件系统的gitbook文件夹挂载到容器里，在浏览器中输入

```
http://localhost:4000
```
##### 就可以访问


#### 第二种 克隆一份代码到容器，并新建一个分支，由环境变量BRANCH设置，默认为master

```
docker run -d -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing \
    -v /root/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v /root/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
	liuxing1981/gitbook
```

```
#利用HTTPS_URL环境变量，只拉取代码进行展示
docker run -d -p 4000:4000 -e HTTPS_URL=https://github.com/liuxing1981/gitbook.git \
	liuxing1981/gitbook
```

```
#建立一个gitbook分支，用于保存文档信息
docker run -d -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing -e BRANCH=gitbook \
    -v /root/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v /root/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
	liuxing1981/gitbook
```
* GIT_URL: git项目的地址
* 注意：配置GIT_URL启动时需要同时制定用户的公钥、私钥，请确保您的用户有项目的权限
* HTTPS_URL: git项目的https地址，用于只读的项目
* BRANCH: 为文档的分支，如果要把文档和代码一起管理，只需要BRANCH=gitbook，建立一个gitbook分支。如果本身git项目就是一个文档，则无需指定。默认BRANCH=master

## 运行原理
1. 克隆项目
2. 检查项目中是否指定有gitbook分支，gitbook分支是存放所有markdown文件的，如果没有则会创建gitbook分支并初始化，然后git push刚建立的gitbook分支到远程git库。如果没有指定，则用master分支
3. 启动cronjob，默认每隔5分钟去git pull代码，可以通过环境变量INTERVAL=3配置，默认为5分钟
4. 启动gitbook服务，监听在4000端口
