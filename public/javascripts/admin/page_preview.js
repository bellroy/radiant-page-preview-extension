document.observe('dom:loaded', function() {
  $('show-preview').observe('click', function(e) {
    e.preventDefault()
    
    var form = this.form,
      oldTarget = form.target,
      oldAction = form.action
    
    try {
      var iframe = $('page-preview').show()
      location.hash = this.id
      form.target = iframe.id
      form.action = '/admin/preview'
      form.submit()
    } finally {
      form.target = oldTarget
      form.action = oldAction
    }
  })
})
