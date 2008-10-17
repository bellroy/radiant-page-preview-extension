class PreviewController < ApplicationController
  skip_before_filter :verify_authenticity_token
  layout false
  def show
    page = page_class.new(params['page'])
    page.slug ||= params[:slug]
    page.breadcrumb ||= params[:breadcrumb]
    page.parent ||= params[:parent_id]
    params['part'].each do |i, attrs|
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
end