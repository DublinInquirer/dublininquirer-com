import GiftForm from './svelte/GiftForm.svelte'
import PaymentForm from './svelte/PaymentForm.svelte'
import SubscribeForm from './svelte/SubscribeForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const giftFormTarget = document.getElementById('gift-form');
  const paymentFormTarget = document.getElementById('payment-form');
  const subscribeFormTarget = document.getElementById('subscribe-form');

  if (!!giftFormTarget) {
    const giftForm = new GiftForm({
      target: giftFormTarget,
      props: {
        formAction: giftFormTarget.getAttribute('data-action'),
        csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
        stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content,
        giftSubscriptionJson: giftFormTarget.getAttribute('data-gift-subscription'),
        planId: giftFormTarget.getAttribute('data-plan')
      }
    });

    window.giftForm = giftForm;
  }

  if (!!paymentFormTarget) {
    const paymentForm = new PaymentForm({
      target: paymentFormTarget,
      props: {
        formAction: paymentFormTarget.getAttribute('data-action'),
        csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
        stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content
      }
    });

    window.paymentForm = paymentForm;
  }


  if (!!subscribeFormTarget) {
    const subscribeForm = new SubscribeForm({
      target: subscribeFormTarget,
      props: {
        formAction: subscribeFormTarget.getAttribute('data-action'),
        csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
        stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content,
        userJson: subscribeFormTarget.getAttribute('data-user'),
        planJson: subscribeFormTarget.getAttribute('data-plan')
      }
    });

    window.subscribeForm = subscribeForm;
  }
})