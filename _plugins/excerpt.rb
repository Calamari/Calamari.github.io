require 'liquid'

module ExcerptFilter

  def excerpt(str)
    return str.split(/<!--\s*more\s*-->/i)[0]
  end

end

Liquid::Template.register_filter(ExcerptFilter)
