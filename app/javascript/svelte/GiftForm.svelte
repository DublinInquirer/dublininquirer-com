<script>
  import { onMount } from 'svelte';
  import { styles, classes, fonts } from './../stripe-elements.js';
  import Field from './Field.svelte';
  import Header from './Header.svelte';

  export let stripePublicKey, formAction, csrfToken, giftSubscriptionJson;

  const stripe = Stripe(stripePublicKey);

  let elements, card, stripeToken;
  let piStatus, piClientSecret, piId;
  let giverGivenName, giverSurname, giverEmailAddress, recipientGivenName, recipientSurname, recipientEmailAddress, planId, duration, price, addressRequired, redemptionCode;
  let giverGivenNameError, giverSurnameError, giverEmailAddressError, recipientGivenNameError, recipientSurnameError, recipientEmailAddressError, paymentError;
  let isSubmitting = false;

  $: purchasePrice = (price / 100);

  function parseGiftSubscriptionData(giftSubscriptionData) {
    const attributes = giftSubscriptionData.attributes;
    const errors = giftSubscriptionData.errors;

    planId = attributes.plan_id;
    duration = attributes.duration;
    price = attributes.price;
    addressRequired = attributes.address_required;
    redemptionCode = attributes.redemption_code;

    giverGivenName = attributes.giver_given_name;
    giverSurname = attributes.giver_surname;
    giverEmailAddress = attributes.giver_email_address;
    
    recipientGivenName = attributes.recipient_given_name;
    recipientSurname = attributes.recipient_surname;
    recipientEmailAddress = attributes.recipient_email_address;

    recipientGivenNameError = errors.recipient_given_name;
    recipientSurnameError = errors.recipient_surname;
    recipientEmailAddressError = errors.recipient_email_address;
  }

  function parsePaymentIntentData(paymentIntentData) {
    piStatus = paymentIntentData.status;
    piClientSecret = paymentIntentData.client_secret;
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
    giverGivenNameError = null;
    giverSurnameError = null;
    giverEmailAddressError = null;
    recipientGivenNameError = null;
    recipientSurnameError = null;
    recipientEmailAddressError = null;
    paymentError = null;
  }

  function nextStepUrl() {
    if (addressRequired) {
      return `/gifts/${redemptionCode}/address`;
    } else {
      return "/gifts/thanks";
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

  function giftSubscriptionParams() {
    return ({
      giver_given_name: giverGivenName,
      giver_surname: giverSurname,
      giver_email_address: giverEmailAddress,
      recipient_given_name: recipientGivenName,
      recipient_surname: recipientSurname,
      recipient_email_address: recipientEmailAddress,
      plan_id: planId,
      duration: duration,
      stripe_id: piId
    });
  }

  function finalisePurchase(data) {
    switch(data.status) { 
      case "ok": {
        parseGiftSubscriptionData(data.gift_subscription);
        window.location.href = nextStepUrl();
        break;
      } 
      case "error": {
        if (!!data.gift_subscription) {
          parseGiftSubscriptionData(data.gift_subscription);
        }
        stopSubmitting();
        break; 
      }
    }
  }

  function startSubmitting() {
    clearErrors();
    isSubmitting = true;
  }

  function stopSubmitting() {
    isSubmitting = false;
  }

  async function confirmCharge() {
    const {paymentIntent, error} =
      await stripe.handleCardPayment(
        piClientSecret,
        card
      );
    if (error) {
      paymentError = 'Unable to authenticate payment card. Try again?';
      stopSubmitting();
    } else {
      piId = paymentIntent.id;
      const response = await fetch('/gifts/confirm',
      {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify({
          gift_subscription: giftSubscriptionParams()
        })
      });
      finalisePurchase(await response.json());
    }
  }

  async function handleServerResponse(data) {
    switch(data.status) { 
      case "ok": {
        // the record is fine, so let's confirm charge
        if (!!data.gift_subscription) { parseGiftSubscriptionData(data.gift_subscription); }
        if (!!data.payment_intent) { parsePaymentIntentData(data.payment_intent); }
        confirmCharge()
        break; 
      } 
      case "error": {
        // the record is not fine
        if (!!data.gift_subscription) { parseGiftSubscriptionData(data.gift_subscription); }
        stopSubmitting();
        break; 
      }
    }
  }

  async function submitForm() {
    const response = await fetch(formAction,
    {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        gift_subscription: giftSubscriptionParams()
      })
    });

    await handleServerResponse(await response.json());
  }

  async function handleFormSubmit(event) {
    startSubmitting();
    submitForm();
  }

  onMount(() => {
    parseGiftSubscriptionData(JSON.parse(giftSubscriptionJson));

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
      <Header>Your details</Header>
      <div class="field">
        <div class="twofer">
          <Field label="Your first name" error={giverGivenNameError}>
            <input type="text" bind:value={giverGivenName} />
          </Field>
          <Field label="Your surname" error={giverSurnameError}>
            <input type="text" bind:value={giverSurname} />
          </Field>
        </div>
      </div>
      <Field label="Your email address" error={giverEmailAddressError}>
        <input type="email" required bind:value={giverEmailAddress} />
      </Field>
    </div>

    <div class="block -b -p2 -my2 -bg-faint">
      <Header>Recipient's details</Header>
      <div class="field">
        <div class="twofer">
          <Field label="First name" error={recipientGivenNameError}>
            <input type="text" bind:value={recipientGivenName} />
          </Field>
          <Field label="Surname" error={recipientSurnameError}>
            <input type="text" bind:value={recipientSurname} />
          </Field>
        </div>
      </div>
      <Field label="Email address" error={recipientEmailAddressError}>
        <input type="email" bind:value={recipientEmailAddress} />
      </Field>
      {#if true}
        <div class="block -mt2">
          <p class="p -centered -t5 c">We won't notify the recipient directly. We need an email address to set up their user account.</p>
        </div>
      {/if}
    </div>

    <div class="block -b -p2 -my2 -bg-faint">
      <Header>Payment details</Header>
      <Field label="Credit/debit card" error={paymentError}>
        <div id="card"></div>
      </Field>
    </div>

    <nav class="block -mt2 actions">
      <button class="button -standard -big" disabled={isSubmitting}>
        {#if isSubmitting}
          &hellip;
        {:else}
          Purchase &mdash; €{purchasePrice}
        {/if}
      </button>
    </nav>
  </div>
</form>