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
# @Desc      :   The usage of ocamloptp under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamloptp -P afilmt example.ml
    CHECK_RESULT $?
    grep -a "/tmp/ocamlpp" a.out
    CHECK_RESULT $?
    ocamloptp --help | grep "ocamloptp"
    CHECK_RESULT $?
    ocamloptp -O2 -remove-unused-arguments example.ml
    CHECK_RESULT $?
    grep -a unused a.out
    CHECK_RESULT $? 1
    ocamloptp -O3 -dflambda-invariants example.ml
    CHECK_RESULT $?
    grep -a invariant a.out
    CHECK_RESULT $?
    ocamloptp -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamloptp -dtimings example.ml | grep "0.0"
    CHECK_RESULT $?
    ocamloptp -dprofile example.ml | grep "0."
    CHECK_RESULT $?
    ocamloptp -no-unbox-specialised-args example.ml
    CHECK_RESULT $?
    grep -a unboxed.caml a.out
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./example* a.out ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
