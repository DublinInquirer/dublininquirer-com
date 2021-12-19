<script>
  import { onMount } from 'svelte';
  import { styles, classes, fonts } from './stripe-elements.js';
  import Field from './Field.svelte';

  export let stripePublicKey, formAction, csrfToken, userJson, planJson;

  const stripe = Stripe(stripePublicKey);

  let elements, card, stripeToken;
  let piStatus, piClientId, piClientSecret;
  let givenName, surname, emailAddress, password, payment, createdAt, amount;
  let givenNameError, surnameError, emailAddressError, passwordError, paymentError, amountError;
  let planId, addressRequired;
  let isSubmitting = false;

  function parseUserData(userData) {
    const attributes = userData.attributes;
    const errors = userData.errors;

    givenName = attributes.given_name;
    surname = attributes.surname;
    emailAddress = attributes.email_address;
    createdAt = attributes.created_at;
    
    givenNameError = errors.given_name;
    surnameError = errors.surname;
    emailAddressError = errors.email_address;
    passwordError = errors.password;
  }

  function parsePlanData(planData) {
    planId = planData.stripe_id;
    addressRequired = planData.address_required;
  }

  function parsePaymentData(paymentData) {
    paymentError = paymentData.error;
  }

  function parseInvoiceData(invoiceData) {
    piStatus = invoiceData.status;
    piClientId = invoiceData.payment_intent_client_id;
    piClientSecret = invoiceData.payment_intent_client_secret;
  }

  function handleScaAction() {
    stripe.handleCardPayment(piClientSecret).then(function(result) {
      if (result.error) {
        paymentError = 'Unable to authenticate payment method. Try another or again?';
        stopSubmitting();
      } else {
        const data = {payment_intent_id: piClientId};
        submitConfirmation(data);
      }
    });
  }

  function clearErrors() {
    givenNameError = null;
    surnameError = null;
    emailAddressError = null;
    passwordError = null;
    paymentError = null;
  }

  function nextStepUrl() {
    if (addressRequired) {
      return "/subscriptions/address";
    } else {
      return "/subscriptions/thanks";
    }
  }

  function getHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': csrfToken
    }
  }

  function startSubmitting() {
    clearErrors();
    isSubmitting = true;
  }

  function stopSubmitting() {
    isSubmitting = false;
  }

  async function submitConfirmation(payload) {
    const response = await fetch('/subscriptions/confirm',
    {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    switch(data.status) { 
      case "ok": {
        window.location.href = nextStepUrl();
        break;
      } 
      case "error": {
        paymentError = 'Unable to authenticate payment card. Try again?';
        stopSubmitting();
        break;
      }
    }
  }

  async function handleServerResponse(data) {
    switch(data.status) { 
      case "ok": { 
        // exit!
        window.location.href = nextStepUrl();
        break; 
      } 
      case "error": {
        // display errors
        if (!!data.user) { parseUserData(data.user); }
        if (!!data.payment) { parsePaymentData(data.payment); }
        stopSubmitting();
        break; 
      }
      case "incomplete": {
        parseInvoiceData(data.invoice);
        handleScaAction();
        break; 
      }
    }
  }

  async function submitFormAndToken(token) {
    stripeToken = token;
    const response = await fetch(formAction,
    {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        user: {
          'given_name': givenName,
          'surname': surname,
          'email_address': emailAddress,
          'password': password
        },
        payment: {'stripe_token': token},
        subscription: {'plan_id': planId}
      })
    });

    await handleServerResponse(await response.json());
  }

  async function handleFormSubmit(event) {
    startSubmitting();
    const {token, error} = await stripe.createToken(card);

    if (error) {
      stopSubmitting();
      paymentError = error.message;
    } else {
      submitFormAndToken(token.id);
    }
  }

  onMount(() => {
    parseUserData(JSON.parse(userJson));
    parsePlanData(JSON.parse(planJson));

    elements = stripe.elements({fonts: fonts});
    card = elements.create('card', {style: styles, classes: classes});
    card.mount('#card');
    
    card.addEventListener('change', ({error}) => {
      stripeToken = null;
      paymentError = error ? error.message : '';
    });
  });
</script>

<style>
</style>

<form on:submit|preventDefault={handleFormSubmit}>
  {#if csrfToken}
    <input type="hidden" name="authenticity_token" bind:value={csrfToken} />
  {/if}

  <div class="block -form">
    <div class="block -b -p2 -my2 -bg-faint">
      <div class="field">
        <div class="twofer">
          <Field label="First name" error={givenNameError}>
            <input type="text" name="user[given_name]" bind:value={givenName} />
          </Field>
          <Field label="Surname" error={surnameError}>
            <input type="text" name="user[surname]" bind:value={surname} />
          </Field>
        </div>
      </div>

      <Field label="Email address" error={emailAddressError}>
        <input type="email" name="user[email_address]" required bind:value={emailAddress} />
      </Field>

      {#if !!!createdAt}
        <Field label="Password" error={passwordError}>
          <input type="password" name="user[password]" required bind:value={password} />
        </Field>
      {/if}
    </div>
      
    <div class="block -b -p2 -my2 -bg-faint">
      <Field label="Credit/debit card" error={paymentError}>
        <div id="card"></div>
      </Field>
    </div>
      
    <div class="block -b -p2 -my2 -bg-faint">
        <Field label="Price" error={amountError}>
          <input type="number" name="user[amount]" required bind:value={amount} />
        </Field>
    </div>

    <nav class="block -mt2 actions">
      <button class="button -standard -big" disabled={isSubmitting}>
        {#if isSubmitting}
          &hellip;
        {:else}
          Subscribe
        {/if}
      </button>
    </nav>
  </div>
</form>