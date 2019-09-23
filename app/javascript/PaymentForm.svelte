<script>
  import { onMount } from 'svelte';
  import { styles, classes, fonts } from './stripe-elements.js';
  import Field from './Field.svelte';

  export let stripePublicKey, formAction, csrfToken, userJson;

  const stripe = Stripe(stripePublicKey);

  let elements, card, stripeToken;
  let piStatus, piClientId, piClientSecret;
  let paymentError;
  let isSubmitting = false;

  $: formDataIsValid = !isSubmitting;

  function parseUserData(userData) {
  }

  function parsePaymentData(paymentData) {
    paymentError = paymentData.error;
  }

  function handleScaAction() {
    stripe.handleCardPayment(piClientSecret).then(function(result) {
      if (result.error) {
        paymentError = 'Unable to authenticate payment method. Try another or again?';
        isSubmitting = false;
      } else {
        const data = {payment_intent_id: piClientId};
        submitConfirmation(data);
      }
    });
  }

  function clearErrors() {
    paymentError = null;
  }

  function handleNextSteps(data) {
    switch(data.status) { 
      case "ok": { 
        // exit!
        window.location.href = '/user'
        break; 
      } 
      case "error": {
        // display errors
        if (!!data.user) { parseUserData(data.user); }
        if (!!data.payment) { parsePaymentData(data.payment); }
        isSubmitting = false;
        break; 
      }
      case "incomplete": {
        parseInvoiceData(data.invoice);
        handleScaAction();
        break; 
      }
    }
  }

  async function submitConfirmation(payload) {
    const response = await fetch('/user/payment/confirm',
    {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    switch(data.status) { 
      case "ok": {
        window.location.href = "/user";
        break;
      } 
      case "error": {
        paymentError = 'Unable to authenticate payment method. Try another or again?';
        isSubmitting = false;
        break;
      }
    }
  }

  async function submitFormWithToken(token) {
    isSubmitting = true;
    const response = await fetch(formAction,
    {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        payment: {
          'stripe_token': stripeToken
        }
      })
    });
    const data = await response.json();
    handleNextSteps(data);
  }

  async function handleSubmit(event) {
    clearErrors();
    const {token, error} = await stripe.createToken(card);

    if (error) {
      paymentError = error.message;
    } else {
      stripeToken = token.id;
      submitFormWithToken(stripeToken);
    }
  }

  onMount(() => {
    parseUserData(JSON.parse(userJson));

    elements = stripe.elements({fonts: fonts});
    card = elements.create('card', {style: styles, classes: classes});
    card.mount('#card');
    
    card.addEventListener('change', ({error}) => {
      stripeToken = null;
      paymentError = error ? error.message : '';
    });
  });
</script>

<form on:submit|preventDefault={handleSubmit}>
  {#if csrfToken}
    <input type="hidden" name="authenticity_token" bind:value={csrfToken} />
  {/if}
  {#if stripeToken}
    <input type="hidden" name="stripe_token" bind:value={stripeToken} />
  {/if}

  <div class="block -form -b -p2 -bg-faint">
    <Field label="Credit/debit card" error={paymentError}>
      <div id="card"></div>
    </Field>
    <nav class="block -mt2 actions">
      <button class="button -standard -big" disabled={!formDataIsValid}>
        {#if isSubmitting}
          &hellip;
        {:else}
          Save changes
        {/if}
      </button>
    </nav>

    <div class="block -mt2">
      <div class="p -t4 -centered c -grey -sf">
        <p>We use <a href="https://www.stripe.com" target="_blank">Stripe</a> to securely handle payment details.</p>
      </div>
    </div>
  </div>
</form>