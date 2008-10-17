# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PagePreviewExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_preview"
  
  # define_routes do |map|
  #   map.connect 'admin/page_preview/:action', :controller => 'admin/page_preview'
  # end
  
  def activate
    # admin.tabs.add "Page Preview", "/admin/page_preview", :after => "Layouts", :visibility => [:all]
    admin.page.edit.add :main, "/preview/show", :after => "edit_buttons"
  end
  
  def deactivate
    # admin.tabs.remove "Page Preview"
  end
  
end