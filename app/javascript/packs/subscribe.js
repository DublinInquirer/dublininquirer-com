import SubscribeForm from '../SubscribeForm.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('subscribe-form');

  const subscribeForm = new SubscribeForm({
    target: target,
    props: {
    }
  });

  window.subscribeForm = subscribeForm;
})
