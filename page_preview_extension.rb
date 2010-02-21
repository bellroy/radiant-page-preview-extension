class PagePreviewExtension < Radiant::Extension
  version "1.0"
  description "Enables previewing pages from the edit screen"
  url "http://github.com/tricycle/raidant-page-preview-extension"
  
  def activate
    admin.page.edit.add :form_bottom, 'preview/preview_iframe', :after => 'edit_buttons'
    Admin::PagesController.helper PagePreviewHelper
  end
end
