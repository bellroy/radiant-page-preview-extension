function preview(button) {
  form = button.form;
  oldtarget = form.target;
  oldaction = form.action;

  $('page-preview').show();

  form.setAttribute('target', 'page-preview');
  form.setAttribute('action', '/admin/preview');
  
  form.submit();

  form.target = oldtarget;
  form.action = oldaction;

  return false;
}
