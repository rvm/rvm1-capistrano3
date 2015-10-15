#!/usr/bin/env bash

script=script/rvm-auto.sh

: errors

## no ruby version given
$script                               # status=101

## wrong ruby given
$script no_ruby_found                 # status=103

## no rvm found
rvm_path=random $script no_ruby_found # status=102

: proper paths

## use ruby from current dir - Gemfile is set to 1.8.7
$script . ruby -v # match=/1.8.7/

## use rvm to make sure 2.2.3 is installed
$script rvm install 2.2.3 # status=0

## use a ruby
$script 2.2.3 ruby -v # match=/2.2.3/

## retest current dir ruby still works
$script . ruby -v # match=/1.8.7/
