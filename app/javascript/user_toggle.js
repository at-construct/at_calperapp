document.addEventListener('DOMContentLoaded', function() {
  var toggle = document.querySelector('.user-toggle');
  toggle.addEventListener('click', function() {
    this.classList.toggle('active');
  });
});