###
# Blog settings
###

activate :i18n
activate :syntax
activate :sprockets do |c|
  c.imported_asset_path = 'imported'
end

Time.zone = "Moscow"

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

activate :blog do |blog|
  blog.prefix = "posts"
  blog.sources = "{year}/{month}-{day}-{title}.html"
  blog.permalink = "{year}/{month}/{day}/{title}.html"
  blog.taglink = "categories/{tag}.html"
  blog.layout = "layout"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  blog.year_link = "{year}.html"
  blog.month_link = "{year}/{month}.html"
  blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.taglink = "categories/{tag}.html"

  blog.calendar_template = "calendar.html"

  blog.paginate = true
  blog.per_page = 3
  blog.page_link = "page/{num}"
end

helpers do
  def current_tagname(tagname = nil)
    @current_tagname ||= begin
      tagname ? tagname : 'Новости'
    end
  end

  # @param options {Hash}
  # => type is :full or :summary
  def article_tag(article, options = {})
    locals = {
      type: :full,
      article: article
    }.merge options

    partial "partials/article", locals: locals
  end
end

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
