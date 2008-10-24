# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PagePreviewExtension < Radiant::Extension
  version "1.0"
  description "Enables previewing pages from the edit screen"
  url "http://github.com/tricycle/raidant-page-preview-extension/"
  
  define_routes do |map|
    map.connect 'admin/preview', :controller => 'preview', :action => 'show'
  end
  
  def activate
    # admin.tabs.add "Page Preview", "/admin/page_preview", :after => "Layouts", :visibility => [:all]
    admin.page.edit.add :form_bottom, "/preview/show", :before => 'edit_buttons'
    admin.page.edit.add :form_bottom, "/preview/preview_iframe", :after => 'edit_buttons'
  end
  
  def deactivate
    # doesn't work
  end

end
