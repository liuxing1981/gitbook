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


#### 第二种 克隆一份代码到容器，并新建一个gitbook分支，这个分支中只有gitbook相关的文档，浏览器显示的是docker容器里git clone下来的gitbook分支的文件。这样每个人在本地修改gitbook的md文件提交后，容器里的定时任务会进行git pull，保证显示gitbook分支的是最新代码。

```
docker run -d -p 4000:4000 -e GIT_URL=git@git.eng.centling.com:testing \
    -v /root/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v /root/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
	liuxing1981/gitbook
```

* GIT_URL: 为git项目的地址,默认会新建分支gitbook
* 注意：启动时需要用用户的公钥、私钥，请确保您的用户有项目的权限

## 运行原理
1. 克隆项目
2. 检查项目中是否有gitbook分支，gitbook分支是存放所有markdown文件的，如果没有则会创建gitbook分支并初始化，然后git push刚建立的gitbook分支到远程git库
3. 启动cronjob，每隔5分钟去git pull代码
4. 启动gitbook服务，监听在4000端口
