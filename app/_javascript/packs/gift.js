import GiftForm from '../GiftForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('gift-form');

  const giftForm = new GiftForm({
    target: target,
    props: {
      formAction: target.getAttribute('data-action'),
      csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
      stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content,
      giftSubscriptionJson: target.getAttribute('data-gift-subscription'),
      planId: target.getAttribute('data-plan')
    }
  });

  window.giftForm = giftForm;
})