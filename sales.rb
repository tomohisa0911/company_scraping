require 'sinatra'
require 'sinatra/reloader'
require 'active_record'
require './mynavi'

# DB定義
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "./db/companyinfo.db"
)


class Company < ActiveRecord::Base
end

class Urllist < ActiveRecord::Base
end


# 一覧表示画面コントローラー
get '/salescrawler' do
  @companies = Company.order("id").all
  @urllists = Urllist.find(1).url
  erb :index
end

# 詳細画面コントローラー
get '/show/:id' do
  @shows = Company.find(params[:id])
  erb :show
end

# クロール先設定ボタンコントローラー
post '/designation' do
  Company.delete_all
  Mynavi.new.infoOut
  redirect '/salescrawler'
end

# 個別削除ボタンコントローラー
post '/delete' do
  Company.find(params[:id]).destroy
end

# URL登録ボタンコントローラー
post '/url_add' do
  Urllist.delete_all
  Urllist.create(:url => params[:url_add])
  redirect '/salescrawler'
end