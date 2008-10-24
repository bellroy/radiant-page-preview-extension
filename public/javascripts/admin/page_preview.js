function preview(button) {
  form = button.form;
  oldtarget = form.target;
  oldaction = form.action;

  $('page-preview').show();
  $('preview-notice').show();

  location.hash = 'show-preview';

  form.target = 'page-preview';
  form.action = '/admin/preview';
  
  form.submit();

  form.target = oldtarget;
  form.action = oldaction;

  return false;
}
