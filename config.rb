###
# Blog settings
###

# time
Time.zone = "Moscow"

# markdown
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

# localization
activate :i18n

activate :blog do |blog|
  blog.prefix = "posts"
  blog.sources = ":year/:month-:day-:title.html"
  blog.permalink = ":year/:month/:day/:title.html"
  blog.taglink = "categories/:tag.html"
  blog.layout = "layout.html"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  blog.year_link = ":year.html"
  blog.month_link = ":year/:month.html"
  blog.day_link = ":year/:month/:day.html"
  blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.taglink = "categories/:tag.html"

  blog.calendar_template = "calendar.html"

  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/:num"
end

page "/feed.xml", layout: false
page "/posts/categories/*", layout: "static"
page "/blog/archive", proxy: "/static_pages/archive.html", layout: "static"

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :encoding, 'utf-8'

sprockets.append_path File.join(root, 'fonts/octicons')

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
