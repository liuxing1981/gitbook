#!/bin/sh
GIT_HOST=`echo $GIT_URL | awk -F: '{print $1}'`
GITBOOK=gitbook
BRANCH=${BRANCH:-master}

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

crontab() {
   GIT_URL=$1
   #add a cronjob to get git changed files
   INTERVAL=${INTERVAL:-3}
   echo "*/$INTERVAL * * * * expect /root/git.exp fetch" > /var/spool/cron/crontabs/root
   crond
}

#https://github.com/liuxing1981/note.git
#git@github.com:liuxing1981/note.git
set_edit_link() {
   if echo $1 | grep "^git" 2>/dev/null;then
       domain=`echo $1 | awk -F@ '{print $2}' | awk -F: '{print $1}'`
       user=`echo $1 | awk -F: '{print $2}' | awk -F/ '{print $1}'`
       repo=`echo $1 | awk -F: '{print $2}' | awk -F/ '{print $2}'`
       repo=`echo $repo | sed 's/\.git//'`
       schema=https
       LINK_URL="$schema://$domain/$user/$repo/edit/$BRANCH/"
   elif echo $1 | grep "^http" 2>/dev/null;then
	   LINK_URL=`echo $1 | sed s/\.git$//`"/edit/$BRANCH/"
   fi
   echo LINK_URL=$LINK_URL
   sed -i "s#LINK_URL#$LINKE_URL#" book.json
}

#set_edit_link https://github.com/liuxing1981/note.git
#set_edit_link git@github.com:liuxing1981/note.git
#exit 0

git config --global user.email "gitbook@example.com"
git config --global user.name "gitbook"
if [ "$GIT_URL" ];then 
   #echo "\$GIT_URL IS NULL use local $PROJECT"  
   git clone $GIT_URL -b $BRANCH $PROJECT
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
   echo "===============GIT_URL=========================================="   
   set_edit_link $GIT_URL
   fi
elif [ "$HTTPS_URL" ];then
   echo "===============HTTPS__URL=========================================="   
    git clone $HTTPS_URL $PROJECT
	set_edit_link $HTTPS_URL
fi 

crontab

chmod -R 777 $PROJECT
cd $PROJECT
#git config core.fileMode false
#if [ ! -e book.json ];then
#    mv /root/book.json .
#    git add book.json
#	echo "add git book"
#	commitFlag=True
#fi
#if [ ! -e "README.md" ];then
#    create_readme
#	git add README.md
#	echo "add README.md"
#	commitFlag=True
#fi
#if [ ! -e "SUMMARY.md" ];then
#    create_summary
#	git add SUMMARY.md
#	echo "add SUMMARY.md"
#	commitFlag=True
#fi
#if [ "$commitFlag" ];then
#	echo "commitFlag= $commitFlag"
#    git commit -m "add book.json"
#	expect /root/git.exp push
#fi
cat book.json
gitbook serve
