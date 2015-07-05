#!/bin/sh

set -e

read -p "ruby version: " ruby_version
# TODO: 未入力の場合、最新バージョンとする(&バリデーション)

read -p "rails version: " rails_version
# TODO: 未入力の場合、最新バージョンとする(&バリデーション)

read -p "rails app name: " rails_app_name
# TODO: 未入力の場合、エラーを出して終了(&バリデーション)

read -p "database user: " database_user
# TODO: 未入力の場合、エラーを出して終了(&バリデーション)

read -sp "database password: " database_password
# TODO: 未入力の場合、エラーを出して終了(&バリデーション)

echo ""

rbenv global $ruby_version
rbenv rehash

cat << EOS > Gemfile
source 'http://rubygems.org'
ruby '$ruby_version'
gem 'rails', '$rails_version'
EOS
echo "### Gemfile created. ###"

bundle install --path vendor/bundle
bundle exec rails new $rails_app_name -BJT -d mysql

rm -rf Gemfile Gemfile.lock vendor/
echo "### remove extra files ###"

cd $rails_app_name

echo "Gemfile:"
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/files/Gemfile" -o Gemfile
echo ".pryrc:"
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/files/.pryrc" -o .pryrc
echo ".gitignore:"
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/files/.gitignore" -o .gitignore
echo "development.rb:"
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/files/development.rb" -o config/environments/development.rb
echo "ja.yml:"
curl "https://raw.githubusercontent.com/suiyujin/rails-init/master/files/ja.yml" -o config/locales/ja.yml

sed -i "" -E "s/^ruby \'.+$/ruby \'${ruby_version}\'/" Gemfile
sed -i "" -E "s/^gem \'rails\', \'.+$/gem \'rails\', \'${rails_version}\'/" Gemfile
echo "### modify Gemfile ###"

bundle install --path vendor/bundle

cp config/database.yml config/database.yml.sample

sed -i "" -e "s/database: ${rails_app_name}_development$/database: ${rails_app_name}_dev/" config/database.yml
sed -i "" -e "s/database: ${rails_app_name}_production$/database: ${rails_app_name}_pro/" config/database.yml
sed -i "" -e "s/username: root$/username: $database_user/" config/database.yml
sed -i "" -e "s/password:$/password: $database_password/" config/database.yml
echo "### modify database.yml ###"

bundle exec rake db:create
echo "### database created. ###"
bundle exec rake db:migrate
echo "### database migrated. ###"

sed -i "" -e "s/# config.time_zone = 'Central Time (US & Canada)'/config.time_zone = 'Tokyo'/" config/application.rb
echo "### reset time_zone ###"
sed -i "" -e "s/# config.i18n.default_locale = :de/config.i18n.default_locale = :ja/" config/application.rb
echo "### reset default_locale ###"

git init
git add .
