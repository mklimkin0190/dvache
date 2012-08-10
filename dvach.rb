# coding: utf-8
require 'sinatra'
require 'mongoid'

set :public_folder, File.dirname(__FILE__) + '/static'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("dvach")
end

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String
  field :image, type: String

  default_scope desc(:created_at)
  scope :empty_posts, where(text: "", image: nil)

  validate :ok

  def ok
  	errors.add(:nooo, "Text and image are both empty!") if text.empty? && image.nil?
  end
end

Post.all.empty_posts.delete_all

get '/' do
	@posts = Post.all

	erb :index
end

post '/' do
	@text = params['text']

	if (failname = params['failname']) && failname[:type] == 'image/jpeg'
		src = failname[:tempfile].path
		dst = "#{Time.now.to_i}.jpg"
		FileUtils.cp(src, "#{settings.public_folder}/#{dst}")
	end

	@post = Post.create(text: @text, image: dst)

	redirect '/'
end

__END__
@@ layout
<html>
  <head>
  	<link href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
  	<title>Два.ч</title>
  </head>

  <body>
  	<div class="container">
  		<%= yield %>
  	</div>
  </body>
</html>

@@ index
<h1>Два.ч</h1>
<%= erb :form %>

<p>Всего постов: <%= @posts.size %></p>
<% @posts.each do |post| %>
	<%= erb :post, locals: {post: post} %>
<% end %>

@@ form
<form action="" method=post enctype="multipart/form-data" class="well form-inline">
	<input type=file name=failname class="span6"><br/>
	<textarea name=text></textarea><br/>
	

	<input type=submit class="btn btn-success">
</form>

@@ post
<div>
	<p><strong><%= post.created_at %></strong></p>

	<% if post.image %>
		<img src="/<%= post.image %>">
	<% end %>
	<p><%= post.text %></p>
</div>