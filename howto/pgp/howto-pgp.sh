#!/usr/bin/env bash

# variable=$(( 1 == 1 ? 1 : 0 ))
# rngd -r /dev/urandom

keyservers=(
pgp.mit.edu
keyserver.ubuntu.com
)

requires() {
    gpg --version > /dev/null
    find --version > /dev/null
    ps > /dev/null
    grep --version > /dev/null
    awk --version > /dev/null
   kill -l > /dev/null
}

# create_config_file filename realname email expire-date passphrase
create_config_file() {
    filename=$1
    realname=$2
    email=$3
    expiration=$4
    passphrase=$5
    cat > ${filename} <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: ${realname}
Name-Email: ${email}
Expire-Date: ${expiration}
Passphrase: ${passphrase}
EOF
}

start_entropy_generation() {
    (find / -xdev -type f -exec sha256sum {} >/dev/null \; 2>&1) &
    export ENTROPY=$!
}
stop_entropy_generation() {
    ps -ef | grep find | awk '{ print $2 }' | grep ${ENTROPY} && kill ${ENTROPY}
    kill $(ps -ef|grep sha256sum|awk '{if($3==1){print $2}}')
    unset ENTROPY
}

gen_key() {
    config_file=${1}
    gpg --batch --gen-key ${config_file} > gpg-keygen.log 2> gpg-keygen_error.log
}

keygen_main() {
    last_umask=$(umask)
    trap 'umask ${last_umask}' EXIT
    filename=$1
    realname=$2
    email=$3
    expiration=$4
    passphrase=$5
    requires
    umask 026
    create_config_file $filename ${realname} ${email} ${expiration} ${passphrase}
}

keygen_main $1 $2 $3 $4 $5

