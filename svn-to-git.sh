#!/bin/bash

# Copyright (c) 2015, Rentabiliweb Group
#
# Permission  to use,  copy, modify,  and/or  distribute this  software for  any
# purpose  with  or without  fee  is hereby  granted,  provided  that the  above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS"  AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO  THIS SOFTWARE INCLUDING  ALL IMPLIED WARRANTIES  OF MERCHANTABILITY
# AND FITNESS.  IN NO EVENT SHALL  THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR  CONSEQUENTIAL DAMAGES OR  ANY DAMAGES WHATSOEVER  RESULTING FROM
# LOSS OF USE, DATA OR PROFITS,  WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER  TORTIOUS ACTION,  ARISING  OUT OF  OR  IN CONNECTION  WITH  THE USE  OR
# PERFORMANCE OF THIS SOFTWARE.

# http://stackoverflow.com/a/3972103/292694

if [ ${#} -lt 3 ]
then
    cat <<EOF
${0}: missing repositories
Usage: ${0} git-name remote-svn-path remote-git-path [author-mapping-file]

eg: ${0} migrate-svn-to-git-with-history https://github.com/rentabiliweb/migrate-svn-to-git-with-history git@github.com:rentabiliweb/migrate-svn-to-git-with-history
EOF
exit 0
fi

which svn > /dev/null
if [ $? -ne 0 ]
then
    echo -e "\\033[31mPlease install svn (see README.md)\\033[39m"
    exit 1
fi

which git > /dev/null
if [ $? -ne 0 ]
then
    echo -e "\\033[31mPlease install git (see README.md)\\033[39m"
    exit 1
fi

ROOT=$(pwd)
NAME=${1}
SRC=${2}
DST=${3}

# Check author file mapping
if [ ${#} -eq 4 ]
then
    AUTHOR_FILE=${4}
    if [ ! -f ${AUTHOR_FILE} ]
    then
        echo "Warning: ${AUTHOR_FILE} not exists."
        exit 1
    fi
fi

# Create svn folder
if [ ! -d ${NAME}-svn ]
then
    mkdir ${NAME}-svn
else
    echo "Warning: ${NAME}-svn already exists."
    exit 1
fi

# Create git folder
if [ ! -d ${NAME}-git ]
then
    mkdir ${NAME}-git
else
    echo "Warning: ${NAME}-git already exists."
    exit 1
fi

# Checkout svn
echo -ne "\\033[39m-- checkout svn"
if [ ${#} -eq 3 ]
then
    git svn clone ${SRC} ${NAME}-svn
else 
    git svn clone ${SRC} ${NAME}-svn --authors-file=${AUTHOR_FILE}
fi
if [ $? -ne 0 ]
then
    echo -e "\\033[31m KO: error on git svn clone"
    exit 1
else
    echo -e "\\033[32m OK"
fi

# Prepare git
echo -ne "\\033[39m-- clone svn to git"
cd ${ROOT}
git clone ${NAME}-svn ${NAME}-git
if [ $? -ne 0 ]
then
    echo -e "\\033[31m KO: error with git clone"
    exit 1
else
    echo -e "\\033[32m OK"
fi

# generate gitignore
echo -ne "\\033[39m-- generate .gitignore"
cd ${ROOT}/${NAME}-svn
git svn show-ignore > ${ROOT}/${NAME}-git/.gitignore
if [ $? -ne 0 ]
then
    echo -e "\\033[31m KO: error on git svn show-ignore"
    exit 1
else
    echo -e "\\033[32m OK"
fi

# Set git remote
echo -ne "\\033[39m-- git remote"
cd ${ROOT}/${NAME}-git
git remote set-url origin ${DST}
if [ $? -ne 0 ]
then
    echo -e "\\033[31m KO: error with git remote set-url origin"
    exit 1
else
    echo -e "\\033[32m OK"
fi

# reset color and print final message
echo -ne "\\033[39m"
cat <<EOF

################################################################################
#
#       Migrate from svn to git with history finished \o/
#
#       Now you need to check commit history and push the code.
#
#       You need to check your .gitignore file.
#
#       cd ${NAME}-git && git log && git push
#
#
################################################################################
EOF
# EOF
