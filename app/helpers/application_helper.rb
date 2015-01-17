module ApplicationHelper

  # like link_to but adds 'btn' class to the link
  def bs_btn( *args, &block )
    if block_given?
      options      = args.first || {}
      html_options = args.second
    else
      name         = args.first
      options      = args.second || {}
      html_options = args.third || {}
      html_options = html_options.stringify_keys
    end
    html_options['class'] ||= ''
    html_options['class'] += ' btn'
    if block_given?
      link_to(options, html_options) do
        yield
      end
    else
      link_to(name, options, html_options)
    end
  end

  def icon_btn(href, icon_name, text='', btn_options={}, icon_options={})
    bs_btn(icon(icon_name, text, icon_options), btn_options)
  end

  def fragment_cache_key(key)
    "fragments/#{key}"
  end

  def json_cache_key(key)
    "json/#{key}"
  end
end
