#!/bin/bash

: ${NAME:=paper}

set -e

pushd `dirname $0` > /dev/null
srcdir=`pwd`
popd

if [ -z ${SKIPDOCKER+x} ]; then
  cat <<EOF | docker build -t pdflatex -
FROM fedora:25
RUN dnf install -y texlive texlive-pbox texlive-appendix texlive-endnotes
RUN dnf install -y texlive-listing
WORKDIR /data
EOF
  docker run -v $srcdir:/data -e SKIPDOCKER=1 \
    -e USERID=$(id -u) -e GROUPID=$(id -g) \
    pdflatex ./build.sh
  exit $?
fi

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

pushd $tmpdir
TEXINPUTS=".:$srcdir:" pdflatex $srcdir/${NAME}
BIBINPUTS="$srcdir"    bibtex ${NAME}
TEXINPUTS=".:$srcdir:" pdflatex $srcdir/${NAME}
TEXINPUTS=".:$srcdir:" pdflatex $srcdir/${NAME}
cp $tmpdir/${NAME}.pdf $srcdir/
if [ ! -z ${USERID+x} ] && [ ! -z ${GROUPID+x} ]; then
  chown $USERID:$GROUPID $srcdir/${NAME}.pdf
fi
popd
