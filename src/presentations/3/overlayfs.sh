#!/usr/bin/env bash

mkdir -p {tmp,merged}
mkdir -p tmp/{a,b,work}

mount -t overlay overlay -o lowerdir=./tmp/a,upperdir=./tmp/b,workdir=./work ./merged