#!/bin/sh

read -p "rails app name:" rails_app_name

rbenv global 2.2.2
rbenv rehash

cat << EOS > Gemfile
source 'http://rubygems.org'
ruby '2.2.2'
gem 'rails', '4.2.1'
EOS

bundle install --path vendor/bundle
bundle exec rails new $rails_app_name -BJT -d mysql

rm -rf Gemfile Gemfile.lock vendor/

cd $rails_app_name

curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/Gemfile" -o Gemfile
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/.pryrc" -o .pryrc
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/.gitignore" -o .gitignore
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/development.rb" -o config/environments/development.rb
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/ja.yml" -o config/locales/ja.yml

bundle install --path vendor/bundle

cp config/database.yml config/database.yml.sample
sed -i "" -e "s/database: ${rails_app_name}_development/database: ${rails_app_name}_dev/" config/database.yml
sed -i "" -e "s/database: ${rails_app_name}_production/database: ${rails_app_name}_pro/" config/database.yml
echo "modify database.yml"

bundle exec rake db:create
bundle exec rake db:migrate

sed -i "" -e "s/# config.time_zone = 'Central Time (US & Canada)'/config.time_zone = 'Tokyo'/" config/application.rb
echo "reset time_zone"
sed -i "" -e "s/# config.i18n.default_locale = :de/config.i18n.default_locale = :ja/" config/application.rb
echo "reset default_locale"

git init
git add .
git status
