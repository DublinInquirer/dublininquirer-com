import { Controller } from '@hotwired/stimulus';
import { loadStripe } from '@stripe/stripe-js';
import { styles, classes, fonts } from './../stripe-elements.js';

// Connects to data-controller="subscibe-form"
export default class extends Controller {
  static targets = [
    'givenNameField',
    'surnameField',
    'emailField',
    'cardField',
    'stripeTokenField',
  ];

  async connect() {
    const stripePublicKey = document.head.querySelector(
      '[name~=stripe-public-key][content]',
    ).content;
    const stripe = await loadStripe(stripePublicKey);
    const elements = stripe.elements({ fonts: fonts });
    const card = elements.create('card', { style: styles, classes: classes });
    card.mount(this.cardFieldTarget);
  }

  subscribe(e) {
    e.preventDefault();
    // STEP 1: Validate the user info
    const validationResponse = this.validateUserData();
    if (validationResponse.status == 'ok') {
      this.sendCardToStripe();
    } else {
      this.displayErrors(validationResponse.errors);
    }
    // STEP 2: Send the card to stripe
    // STEP 3: persist the stripe token
    // STEP 4: actually submit the thing
    // }
  }

  // should reply with {status: "ok"} or {status: "error", errors: {}}
  validateUserData() {
    fetch('/v2/subscribe/validate', {
      method: 'POST',
      body: new FormData(this.element),
    }).then((data) => {
      console.log('Success:', data);
    });
  }

  displayErrors(errors) {
    console.log(errors);
  }

  sendCardToStripe() {
    console.log('SEND CARD TO STRIPE');
  }

  // connect() {
  //   this.boundFindFoo = this.findFoo.bind(this);
  //   document.addEventListener('click', this.boundFindFoo);
  // }

  // disconnect() {
  //   document.removeEventListener('click', this.boundFindFoo);
  // }

  // findFoo() {
  //   console.log(this.element.querySelector('#foo'));
  // }
}
