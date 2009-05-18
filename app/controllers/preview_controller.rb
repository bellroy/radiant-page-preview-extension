class ClassChangedException < Exception; end

class PreviewController < ApplicationController
  layout false
  def show
    Page.transaction do # Extra safe don't save anything voodoo
      PagePart.transaction do
        def request.request_method; :get; end
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
    if request.referer =~ %r{/admin/pages/(\d+)/edit}
      page = Page.find($1).becomes(page_class)
      page.update_attributes(params[:page])
    else
      page = page_class.new(params[:page])
      page.published_at = page.updated_at = page.created_at = Time.now
      page.parent = Page.find($1) if request.referer =~ %r{/admin/pages/(\d+)/children/new}
    end
    return page
  end
end
