<script>
  import { onMount } from 'svelte';

  export let formAction;

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
</script>

<style>
</style>

<slot></slot>