ActionController::Routing::Routes.draw do |map|
  map.connect 'admin/preview', :controller => 'preview', :action => 'show'
end
