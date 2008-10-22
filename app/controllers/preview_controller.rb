class ClassChangedException < Exception; end

class PreviewController < ApplicationController
  layout false
  def show
    Page.transaction do # Extra safe don't save anything voodoo
      PagePart.transaction do
        construct_page.process(request,response)
        @performed_render = true
        raise "Don't you dare save any changes" 
      end
    end
  rescue => exception
    render :text => exception.message unless @performed_render
  end
  
  private
  def page_class
    classname = params[:page][:class_name].classify
    if Page.descendants.collect(&:name).include?(classname)
      classname.constantize
    else
      Page
    end
  end
  
  def construct_page
    if request.referer =~ %r{/admin/pages/(\d+)/child/new}
      page = page_class.new(params[:page])
      page.parent = Page.find($1)
    elsif request.referer =~ %r{/admin/pages/edit/(\d+)}
      page = Page.find($1).becomes(page_class)
      page.parts = []
      page.attributes = params[:page]
    else
      page = page_class.new(params[:page])
    end
    params.fetch(:part, []).each do |i, attrs|
      page.parts.build(attrs)
    end
    return page
  end
end
