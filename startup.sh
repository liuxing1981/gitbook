#!/bin/sh
GIT_HOST=`echo $GIT_URL | awk -F: '{print $1}'`
GITBOOK=gitbook
BRANCH=gitbook

gitbook_init() {
cat >README.md <<-! 
# README

This is a book powered by [GitBook](https://github.com/GitbookIO/gitbook).
Try to edit markdown files by [Markdown Editor](https://jbt.github.io/markdown-editor/).
Or create a gitbook by [Gitbook Editor](https://www.gitbook.com/editor).
!

cat >SUMMARY.md <<-!
# SUMMARY

* [Chapter1](chapter1/README.md)
* [Section1.1](chapter1/section1.1.md)
* [Section1.2](chapter1/section1.2.md)
* [Chapter2](chapter2/README.md)
!
}


if [ ! $GIT_URL ];then  
   echo "\$GIT_URL IS NULL use local $PROJECT"  
else
   git config --global user.email "gitbook@example.com"
   git config --global user.name "gitbook"
   git config --global core.sshCommand "ssh -o StrictHostKeyChecking=no -F /dev/null"
   rm -rf /root/.ssh/known_hosts
   echo "======rm known_hosts=========="
   
   expect -c "
    set timeout 1;
    spawn ssh $GIT_HOST; 
    expect \"(yes/no)?\" {send \"yes\n\"};
    expect *# {send exit\n};
    expect eof;" >/tmp/log
    
   git clone -b $BRANCH $GIT_URL $PROJECT
   
   #branch not exist,need to create a new branch named gitbook
   if [ $? != 0 ];then
        echo "========create branch=============="
        rm -rf $PROJECT
	git clone $GIT_URL $PROJECT
        cd $PROJECT
        git checkout -b $BRANCH
        rm -rf *
        gitbook_init
        echo "==========git commit=============================="
        git commit -am "init gitbook"
        #git pull origin $BRANCH --rebase
        git push origin $BRANCH
   fi
   echo "===============end=========================================="   
   #add a cronjob to get git changed files
   [ ! "$INTERVAL" ] && INTERVAL=5
   echo "*/$INTERVAL * * * * cd $PROJECT && git pull origin $BRANCH --rebase" > /var/spool/cron/crontabs/root
   crond
fi  
cd $PROJECT && gitbook serve
