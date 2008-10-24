function preview(button) {
  form = button.form;
  oldtarget = form.target;
  oldaction = form.action;

  $('page-preview').show();

  form.setAttribute('target', 'page-preview');
  form.setAttribute('action', '/admin/preview');


  window.setTimeout(function() {
    form.target = oldtarget;
    form.action = oldaction;
  }, 1000);
}
