<script>
  import { onMount } from 'svelte';
  import { styles, classes, fonts } from './stripe-elements.js';
  import Field from './Field.svelte';

  export let stripePublicKey, formAction, csrfToken, userJson, planId;

  const stripe = Stripe(stripePublicKey);

  let elements, card, stripeToken, form;
  let givenName, surname, emailAddress, password, payment, createdAt;
  let givenNameError, surnameError, emailAddressError, passwordError, paymentError;

  $: formDataIsValid = validateUserData(givenName, surname, emailAddress, password, createdAt, stripeToken);

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
    paymentError = errors.payment;
  }

  function validateUserData(givenName, surname, emailAddress, password, createdAt, stripeToken) {
    if (!!emailAddress && emailAddress.length < 3) {
      emailAddressError = "can't be blank";
    } else {
      emailAddressError = null;
    }

    if (!!!createdAt && (!!password && password.length < 6)) {
      passwordError = 'must be at least 6 characters';
    } else {
      passwordError = null;
    }

    if (!!givenNameError || !!surnameError || !! emailAddressError || !! passwordError || !!paymentError) {
      return false;
    } else {
      return true;
    }
  }

  async function submitFormWithToken(token) {
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
        user: {
          'given_name': givenName,
          'surname': surname,
          'email_address': emailAddress,
          'password': password
        },
        payment: {
          'stripe_token': stripeToken
        },
        subscription: {
          'plan_id': planId
        }
      })
    });
    const data = await response.json();

    switch(data.status) { 
      case "ok": { 
        window.location.href = '/subscriptions/thanks'
        break; 
      } 
      case "error": { 
        parseUserData(data.user);
        break; 
      }
      case "incomplete": {
        console.log("Incomplete");
        break; 
      }
    }
  }

  async function handleSubmit(event) {
    const {token, error} = await stripe.createToken(card);

    if (error) {
      paymentError = error.message;
    } else {
      stripeToken = token.id;

      // fetch
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

<style>
</style>

<form action={formAction} method='post' on:submit|preventDefault={handleSubmit} bind:this={form}>
  {#if csrfToken}
    <input type="hidden" name="authenticity_token" bind:value={csrfToken} />
  {/if}
  {#if stripeToken}
    <input type="hidden" name="stripe_token" bind:value={stripeToken} />
  {/if}

  <div class="block -form">
    <div class="block -b -p2 -my2 -bg-faint">
      <div class="field">
        <div class="twofer">
          <Field label="Given name" error={givenNameError}>
            <input type="text" name="user[given_name]" bind:value={givenName} />
          </Field>
          <Field label="Surname" error={surnameError}>
            <input type="text" name="user[surname]" bind:value={surname} />
          </Field>
        </div>
      </div>

      <Field label="Email address" error={emailAddressError}>
        <input type="email" name="user[email_address]" bind:value={emailAddress} />
      </Field>

      {#if !!!createdAt}
        <Field label="Password" error={passwordError}>
          <input type="password" name="user[password]" bind:value={password} />
        </Field>
      {/if}
    </div>
      
    <div class="block -b -p2 -my2 -bg-faint">
      <Field label="Credit/debit card" error={paymentError}>
        <div id="card"></div>
      </Field>
    </div>
    <nav class="block -mt2 actions">
      <button class="button -standard -big" disabled={!formDataIsValid}>Submit</button>
    </nav>
  </div>
</form>