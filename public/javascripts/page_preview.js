function write_to_iframe(text) {
  // delete page-preview if it exists
  if ( $('page-preview') )
    $('page-preview').parentNode.removeChild($('page-preview'));
  var iframe = document.createElement('iframe');
  iframe.id = 'page-preview';
  iframe.setAttribute('frameborder','0');
  iframe.setAttribute('src','/blank-iframe.html');
  iframe.style.width = "100%";
  iframe.style.height = "40em";
  iframe.style.display = "none";
  iframe.style.border = "1px solid black";
  iframe.style.marginTop = '0.3em';
  $('preview_container').appendChild(iframe);
  var doc = $('page-preview').contentDocument;
  if (doc == undefined || doc == null)
    doc = $('page-preview').contentWindow.document;
  doc.open();
  doc.write(text);
  doc.close();
  $('page-preview').show();
}
function preview() {
  new Ajax.Request('/admin/preview', {
    method: 'post',
    parameters: Form.serialize(document.forms[0]),
    onSuccess: function(response) { write_to_iframe(response.responseText); } 
  })
  write_to_iframe("Loading…");
  $('page-preview').style.display = 'block';
}
