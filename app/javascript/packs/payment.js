import PaymentForm from '../PaymentForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('payment-form');

  const paymentForm = new PaymentForm({
    target: target,
    props: {
      formAction: target.getAttribute('data-action'),
      csrfToken: document.head.querySelector("[name~=csrf-token][content]").content,
      stripePublicKey: document.head.querySelector("[name~=stripe-public-key][content]").content
    }
  });

  window.paymentForm = paymentForm;
})