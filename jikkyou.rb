# coding: utf-8
require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'

require 'byebug' if development?
require 'haml'
require 'pony'

require "sinatra/config_file"

enable :sessions
set :session_secret, "My session secret"

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: "db/development.sqlite3"
)

#グループごとのDB
class Group < ActiveRecord::Base
end

#ユーザーごとのDB
class User < ActiveRecord::Base
end

#チャンネルごとのDB
class Channel < ActiveRecord::Base
end

#コンテンツごとのDB

class Content < ActiveRecord::Base
end

use Rack::MethodOverride

class MainApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure :development do
    register Sinatra::ConfigFile
    config_file 'config.yml'
    settings.path_prefix = ''
  end

  configure :production do
    register Sinatra::ConfigFile
    config_file 'config.yml'
    settings.path_prefix = ''
  end


  before do
    @path_prefix = settings.path_prefix
  end

  get '/' do
    groups = Group.all
    @channels = Channel.all
    @grouplist = []
    @namelist = []
    @minilist = []
    @idlist = []
    daylist = []
    @daylist = []
    @interlist = []
    @nillist = []
    #トップに表示するユーザ3人をグループごとに決定
    groups.each do |group|
      tmporder = group.noworder
      users = User.where(:groupid => group.id.to_s).sort_by{|user| user.order}
      if users.size == 0
        @nillist.push(true)
      else
        @nillist.push(false)
      end
      #byebug if development?
      size = 3
      num = 0
      tmplist = []
      daylist = []
      while num != size do
        tmplist.push(users[tmporder])
        tmporder += 1
        if tmporder == users.size
          tmporder = 0
        end
        num += 1
      end
      #時間の取得
      day = Time.now
      while day.wday != 1 do
        day -= 24*60*60
      end
      if group.interval > 1
        day -= 24*60*60*7*(group.interval - 1)
      end
      4.times() do
        d = day.year.to_s + "/" + "%02d" % day.month.to_s  + "/" + "%02d" % day.day.to_s
        daylist.push(d)
        day += 24*60*60*7
      end
      @daylist.push(daylist)
      @grouplist.push(tmplist)
      @namelist.push(group.name)
      @minilist.push(group.mini)
      @idlist.push(group.id)
      @interlist.push(group.interval)
    end
    haml :top
  end


  #チャンネル作成ページ
  get '/channels/new' do
    channel = Channel.new(:title => params[:title],:elapsetime => params[:etime], :starttime => params[:stime],:rows => params[:rows],:defaultname => params[:dname])
    channel.save
    rtn = {
        id: channel.id,
        title: channel.title,
        stime: channel.starttime
    }
    rtn.to_json
  end

  #チャンネル作成ページ(POST)
  post '/channels/new' do
    channel = Channel.new(:title => params[:title],:elapsetime => params[:etime], :starttime => params[:stime],:rows => params[:rows],:defaultname => params[:dname])
    channel.save
    rtn = {
        id: channel.id,
        title: channel.title,
        stime: channel.starttime
    }
    rtn.to_json
  end

  #チャンネル一覧ページ
  get '/channel/list' do
    @allchannel = Channel.all.sort_by{|channel| channel.id}.reverse
    #月別リスト作成
    @monthlist = []
    nowmonth = 0
    @allchannel.each_with_index do |channel,i|
      tmpmonth = channel.starttime.split("/")[0].to_i*12 + channel.starttime.split("/")[1].to_i
      if tmpmonth != nowmonth
        @monthlist.push(tmpmonth)
        nowmonth = tmpmonth
      end
    end
    haml :channellist
  end


  #実況終了時チャンネル更新ページ
  get '/channels/end' do
    channel = Channel.where(:id => params[:cid])[0]
    channel.rows = params[:rows]
    channel.elapsetime = params[:etime]
    channel.save
    rtn = {
        id: channel.id,
        title: channel.title,
        stime: channel.starttime
    }
    rtn.to_json
  end

  #実況終了時チャンネル更新ページ(POST)
  post '/channels/end' do
    channel = Channel.where(:id => params[:cid])[0]
    channel.rows = params[:rows]
    channel.elapsetime = params[:etime]
    channel.save
    rtn = {
        id: channel.id,
        title: channel.title,
        stime: channel.starttime
    }
    rtn.to_json
  end

  #コンテンツ作成ページ
  get '/contents/new' do
    content = Content.new(:channelid => params[:cid],:tweets => params[:tweets],:nowtime  => params[:ntime], :tweetstime => params[:ttime],:value => params[:value])
    content.save
    rtn = {
        id: content.id,
        channelid: content.channelid,
    }
    rtn.to_json
  end

  #コンテンツ作成ページ(POST)
  post '/contents/new' do
    content = Content.new(:channelid => params[:cid],:tweets => params[:tweets],:nowtime  => params[:ntime], :tweetstime => params[:ttime],:value => params[:value] )
    content.save
    rtn = {
        id: content.id,
        channelid: content.channelid,
    }
    rtn.to_json
  end

  post '/' do
    group = Group.new(:name => params[:name],:mini => params[:mini],:interval => 0,:renew => 0,:noworder => 0)
    group.save
    redirect "#{@path_prefix}/"
  end

  #それぞれの実況詳細画面
  get '/channel/detail/:id' do
    @channel = Channel.where(:id => params[:id])[0]
    @contents = Content.where(:channelid => @channel.id)
    #sidebar表示用
    @allchannel = Channel.all.sort_by{|channel| channel.id}.reverse
    #月別リスト作成
    @monthlist = []
    nowmonth = 0
    @allchannel.each_with_index do |channel,i|
      tmpmonth = channel.starttime.split("/")[0].to_i*12 + channel.starttime.split("/")[1].to_i
      if tmpmonth != nowmonth
        @monthlist.push(tmpmonth)
        nowmonth = tmpmonth
      end
    end
    haml :jikkyoudetail
  end

  #月別リスト表示
  get '/channel/month/:id' do
    @allchannel = Channel.all.sort_by{|channel| channel.id}.reverse
    #その月のリスト
    @monthchannel = []
    #月別リスト作成
    @monthlist = []
    nowmonth = 0

    #登録
    @allchannel.each_with_index do |channel,i|
      tmpmonth = channel.starttime.split("/")[0].to_i*12 + channel.starttime.split("/")[1].to_i
      if tmpmonth == params[:id].to_i
        @monthchannel.push(channel)
      end
      if tmpmonth != nowmonth
        @monthlist.push(tmpmonth)
        nowmonth = tmpmonth
      end
    end
    haml :monthchannel
  end

end