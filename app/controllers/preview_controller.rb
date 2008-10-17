class PreviewController < ApplicationController
  skip_before_filter :verify_authenticity_token
  layout false
  def show
    page = get_page
    params.fetch('part', []).each do |i, attrs|
      page.parts << PagePart.new(attrs)
    end
    page.process(request,response)
    @performed_render = true
  end
  
  private
  def page_class
    classname = params['page']['class_name'].classify
    if Page.descendants.collect(&:name).include?(classname)
      classname.constantize
    else
      Page
    end
  end
  
  def get_page
    if request.referer =~ %r{/admin/pages/(\d+)/child/new}
      page = page_class.new(params['page'])
      page.parent = Page.find($1)
    elsif request.referer =~ %r{/admin/pages/edit/(\d+)}
      page = Page.find($1)
      page.attributes = params['page']
    end
    return page
  end
end