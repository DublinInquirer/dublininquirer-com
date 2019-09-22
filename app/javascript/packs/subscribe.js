import SubscribeForm from '../SubscribeForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('subscribe-form');

  const subscribeForm = new SubscribeForm({
    target: target,
    props: {
      formAction: target.getAttribute('data-action'),
      csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
      stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content,
      userJson: target.getAttribute('data-user'),
      planId: target.getAttribute('data-plan')
    }
  });

  window.subscribeForm = subscribeForm;
})