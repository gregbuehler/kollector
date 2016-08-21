require 'sinatra/base'
require 'digest'
require 'data_mapper'
require 'json'
require 'uri'
#require 'sinatra/cross_origin'

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper::Model.raise_on_save_failure = true

class Link
    include DataMapper::Resource

    property :id,           Serial
    property :tag,          String
    property :link,         String, :length => 255
    property :url,          String, :length => 255
end

class Click
    include DataMapper::Resource

    property :id,           Serial
    property :timestamp,    DateTime
    property :tag,          String
    property :ip,           String
    property :fingerprint,  String
    property :referrer,     String, :length => 255
end

def fingerprint(request)
  Digest::MD5.hexdigest("#{request.ip} #{request.user_agent}").to_s
end

def record_click(tag, ip, fingerprint, referrer)
  c = Click.new
  c.timestamp = DateTime.now
  c.tag = tag
  c.ip = ip
  c.fingerprint = fingerprint
  c.referrer = referrer
  c.save
end

def create_tag(url)
  hash = Digest::SHA1.hexdigest("#{DateTime.now.to_s} #{url}").to_s[0..5]
  link = "#{request.scheme.to_s}://#{request.host.to_s}:#{request.port.to_s}/l/#{hash}"

  l = Link.new
  l.tag = hash
  l.link = link
  l.url = url
  l.save

  return l
end

Link.auto_migrate!
Click.auto_migrate!

class Kollector < Sinatra::Base

  set :public_folder, Proc.new { File.join(root, "public") }
  set :root_folder, Proc.new { File.join(root) }
  set :cross_origin, true

  get '/' do
    erb :index
  end

  post '/l' do
    begin
      u = URI.parse(params[:url])
      if u.scheme === nil; puts "scheme was nil"; raise; end
      create_tag(params[:url]).to_json
    rescue
      status 400
    end
  end

  get '/l' do
    tags = Link.all
    puts "No. of tags", Link.all.length
    erb :list, :locals => { :tags => tags }
  end

  get '/l/:tag' do
    t = Link.first(:tag => params[:tag])
    if not t.nil?
      record_click(t.tag, request.ip, fingerprint(request), request.referrer)
      redirect(t.url)
    else
      puts "couldn't find tag"
    end

  end

  get '/c/:tag' do
    clicks = Click.all(:tag => params[:tag])
    erb :stats, :locals => { :clicks => clicks }
  end
end
