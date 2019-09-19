import SubscribeForm from '../SubscribeForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('subscribe-form');

  const subscribeForm = new SubscribeForm({
    target: target,
    props: {
      formAction: target.getAttribute('data-action'),
      csrfToken: document.head.querySelector("[name~=csrf-token][content]").content
    }
  });

  window.subscribeForm = subscribeForm;
})


$('meta[name="csrf-token"]').attr('content')