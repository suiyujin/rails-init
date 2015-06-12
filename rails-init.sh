#!/bin/sh

read -p "rails app name:" rails_app_name
echo $rails_app_name

rbenv global 2.2.2
rbenv rehash

cat << EOS > Gemfile
source 'http://rubygems.org'
ruby '2.2.2'
gem 'rails', '4.2.1'
EOS

bundle install --path vendor/bundle

bundle exec rails new $rails_app_name -BJT -d mysql

cd $rails_app_name


