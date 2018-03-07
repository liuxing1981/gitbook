#!/bin/sh
GIT_HOST=`echo $GIT_URL | awk -F: '{print $1}'`
GITBOOK=gitbook
BRANCH=gitbook

create_readme() {
cat >README.md <<-! 
# README

This is a book powered by [GitBook](https://github.com/GitbookIO/gitbook).
Try to edit markdown files by [Markdown Editor](https://jbt.github.io/markdown-editor/).
Or create a gitbook by [Gitbook Editor](https://www.gitbook.com/editor).
!
}

create_summary() {
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
   git clone -b $BRANCH $GIT_URL $PROJECT
   
   #branch not exist,need to create a new branch named gitbook
   if [ $? != 0 ];then
        echo "========create branch=============="
        rm -rf $PROJECT
	git clone $GIT_URL $PROJECT
        cd $PROJECT
        git checkout -b $BRANCH
        rm -rf *
        create_readme
        create_summary
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
chmod -R 777 $PROJECT
cd $PROJECT 
if [ ! -e "README.md" ];then
    create_readme
fi
if [ ! -e "SUMMARY.md" ];then
    create_summary
fi
gitbook serve
