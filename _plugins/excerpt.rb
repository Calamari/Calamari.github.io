require 'liquid'

module ExcerptFilter

  def excerpt(str)
    return str.split('<!--more-->')[0]
  end

end

Liquid::Template.register_filter(ExcerptFilter)
