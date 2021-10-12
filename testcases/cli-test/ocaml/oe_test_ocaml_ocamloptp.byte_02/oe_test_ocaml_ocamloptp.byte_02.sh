#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/11/6
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamloptp.byte under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../example.ml ../not.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamloptp.byte -inline-prim-cost 3 example.ml
    CHECK_RESULT $?
    grep -a "prim" a.out
    CHECK_RESULT $?
    ocamloptp.byte -inline-indirect-cost 4 example.ml
    CHECK_RESULT $?
    grep -a "directory.camlStdlib" a.out
    CHECK_RESULT $?
    ocamloptp.byte -inline-toplevel 100 example.ml
    CHECK_RESULT $?
    grep -a "level.camlStdlib" a.out
    CHECK_RESULT $?
    ocamloptp.byte -S -inline-call-cost 1 not.ml -o not.opt
    CHECK_RESULT $?
    grep call not.s
    CHECK_RESULT $?
    ocamloptp.byte -inline-max-depth 1 example.ml
    CHECK_RESULT $?
    grep -a "max " a.out
    CHECK_RESULT $?
    ocamloptp.byte -linscan example.ml
    CHECK_RESULT $?
    strings a.out | grep "scan_line"
    CHECK_RESULT $?
    ocamloptp.byte -no-float-const-prop example.ml
    CHECK_RESULT $?
    strings a.out | grep "const_prop"
    CHECK_RESULT $? 1
    ocamloptp.byte -nodynlink example.ml
    CHECK_RESULT $?
    strings a.out | grep "r9wE"
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.out ./example* ./not* ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
