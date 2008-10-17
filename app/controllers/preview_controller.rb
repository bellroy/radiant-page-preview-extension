class PreviewController < ApplicationController
  skip_before_filter :verify_authenticity_token
  layout false
  def show
    page = page_class.new(params['page'])
    page.parent = parent
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
  
  def parent
    if request.referer =~ %r{/admin/pages/(\d+)/child/new}
      Page.find($1)
    elsif request.referer =~ %r{/admin/pages/edit/(\d+)}
      Page.find($1).parent
    else
      nil
    end
  end
end