#!/bin/sh
GITBOOK=gitbook
if [ ! $GIT_URL ];then  
   GITBOOK_HOME=$PROJECT
   echo "\$GIT_URL IS NULL use local $GITBOOK_HOME"  
else  
   GITBOOK_HOME=$PROJECT/$GITBOOK
   git config --global user.email "gitbook@example.com"
   git config --global user.name "gitbook"
   git config --global core.sshCommand "ssh -o StrictHostKeyChecking=no -F /dev/null"
   expect -c "
    set timeout 1;
    spawn git clone $GIT_URL $PROJECT
    expect \"(yes/no)?\" {send \"yes\n\"};
    expect * {send exit\n};
    expect eof;"
   #init gitbook dir
   if [ ! -d "$GITBOOK_HOME" ];then
		mkdir -p $GITBOOK_HOME
		cd $PROJECT
cat >$GITBOOK/README.md <<-!
# README

This is a book powered by [GitBook](https://github.com/GitbookIO/gitbook).
Try to edit markdown files by [Markdown Editor](https://jbt.github.io/markdown-editor/). 
Or create a gitbook by [Gitbook Editor](https://www.gitbook.com/editor).
!
cat >$GITBOOK/SUMMARY.md <<-!
# SUMMARY

* [Chapter1](chapter1/README.md)
* [Section1.1](chapter1/section1.1.md)
* [Section1.2](chapter1/section1.2.md)
* [Chapter2](chapter2/README.md)
!
      git add -A && git commit -m "make gitbook dir" && git pull --rebase && git push
   fi
   #add a cronjob to get git changed files
   [ ! "$INTERVAL" ] && INTERVAL=5
   echo "*/$INTERVAL * * * * cd $PROJECT && git pull --rebase" > /var/spool/cron/crontabs/root
   crond
fi  
cd $GITBOOK_HOME && gitbook serve
