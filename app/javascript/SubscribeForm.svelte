<script>
  import { onMount } from 'svelte';

  export let formAction;
  export let csrfToken;

  let stripeErrorMessage;
  let stripeToken;

  let formIsValid = true;

  const elements = stripe.elements({
    fonts: [
      {
        family: 'Zirkon',
        src: 'url(https://d1trxack2ykyus.cloudfront.net/fonts/GT-Zirkon-Light.woff2)',
        style: 'normal',
        weight: '400'
      }
    ]
  });

  const styles = {
    base: {
      color: '#070707',
      fontWeight: '400',
      fontFamily: '"Zirkon", sans-serif',
      fontSize: '17.5px',
      fontSmoothing: 'optimizeLegibility',
      ':focus': {
        color: '#000'
      },
      '::placeholder': {
        color: '#999'
      },
      ':focus::placeholder': {
        color: '#DDD'
      }
    },
    invalid: {
      color: '#FC4604',
      ':focus': {
        color: '#070707'
      },
      '::placeholder': {
        color: '#FED1C0'
      }
    }
  };

  const classes = {
    focus: '-focus',
    empty: '-empty',
    invalid: '-invalid'
  };

  const card = elements.create('card', {
    style: styles,
    classes: classes
  });

  async function handleSubmit(event) {
    const {token, error} = await stripe.createToken(card);
    const form = event.target;
    if (error) {
      stripeErrorMessage = error.message;
    } else {
      stripeToken = token.id;
      console.log('Submit form');
    }
  }

	onMount(async () => {
    card.mount('#card');
    card.addEventListener('change', ({error}) => {
      if (stripeToken) {
        stripeToken = null;
      }
      if (error) {
        stripeErrorMessage = error.message;
      } else {
        stripeErrorMessage = '';
      }
    });
  });
</script>

<style>
</style>

<form action={formAction} method='post' on:submit|preventDefault={handleSubmit}>
  {#if csrfToken}
    <input type="hidden" name="authenticity_token" bind:value={csrfToken} />
  {/if}
  {#if stripeToken}
    <input type="hidden" name="stripe_token" bind:value={stripeToken} />
  {/if}

  <div class="block -form">
    <div class="block -b -p2 -my2 -bg-faint">
      <div class="field">
        <label>Payment details</label>
        <div id="card"></div>
        {#if stripeErrorMessage}
          <div class="error">{stripeErrorMessage}</div>
        {/if}
      </div>
    </div>
    
    <nav class="block -mt2 actions">
      <button class="button -standard -big" disabled={!!stripeToken}>Subscribe</button>
    </nav>
  </div>
</form>