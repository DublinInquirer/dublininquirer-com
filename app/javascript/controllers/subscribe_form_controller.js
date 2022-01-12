import { Controller } from '@hotwired/stimulus';
import { loadStripe } from '@stripe/stripe-js';
import { styles, classes, fonts } from './../stripe-elements.js';

// Connects to data-controller="subscribe-form"
export default class extends Controller {
  static targets = [
    'givenNameField',
    'surnameField',
    'emailAddressField',
    'passwordField',
    'cardField',
    'cardFieldInput',
    'stripeTokenField',
    'submitButton',
  ];

  connect() {
    const stripePublicKey = document.head.querySelector(
      '[name~=stripe-public-key][content]',
    ).content;
    const card = loadStripe(stripePublicKey)
      .then(this.setElements)
      .then(this.createCard)
      .then((card) => this.mountCard(card));
  }

  setElements(stripe) {
    return stripe.elements({ fonts: fonts });
  }

  createCard(elements) {
    return elements.create('card', { style: styles, classes: classes });
  }

  mountCard(card) {
    card.mount(this.cardFieldInputTarget);
  }

  // STEP 1: Validate the user info server-side
  // STEP 2: Validate card info with Stripe
  // STEP 3: Persist Stripe token
  // STEP 4: Submit the thing, set up the payment and confirm the payment
  // /validate should reply with {status: "ok"} or {status: "error", errors: {}}

  subscribe(e) {
    e.preventDefault();

    this.disableSubmit();
    this.clearErrors();
    this.validateUserData()
      .then((response) => this.handleUserValidationResponse(response))
      .then((_res) => this.validateCardData())
      .catch((err) => {
        console.log(err);
        null;
      });
  }

  validateUserData() {
    return fetch('/v2/subscribe/validate', {
      method: 'POST',
      body: new FormData(this.element),
    })
      .then((response) => response.json())
      .catch((err) => {
        null;
      });
  }

  validateCardData() {
    console.log(this);
  }

  handleUserValidationResponse(response) {
    if (response.status == 200) {
      return 200;
    } else {
      this.displayErrors(response['errors']);
      this.undisableSubmit();
      throw new Error(response['errors']);
      return null;
    }
  }

  displayErrors(errors) {
    for (const field in errors) {
      let target;
      // lol
      switch (field) {
        case 'given_name': {
          target = this.givenNameFieldTarget;
          break;
        }
        case 'surname': {
          target = this.surnameFieldTarget;
          break;
        }
        case 'email_address': {
          target = this.emailAddressFieldTarget;
          break;
        }
        case 'password': {
          target = this.passwordFieldTarget;
          break;
        }
        case 'card': {
          target = this.cardFieldTarget;
          break;
        }
      }

      let errorEl = target.querySelector('.error');

      if (target.querySelector('.error') == null) {
        errorEl = document.createElement('div');
        errorEl.classList.add('error');
        target.appendChild(errorEl);
      }

      errorEl.innerHTML = errors[field];
    }
  }

  clearErrors() {
    this.element.querySelectorAll('.error').forEach(function (errorEl) {
      errorEl.innerHTML = '';
    });
  }

  disableSubmit() {
    this.submitButtonTarget.disabled = true;
    this.submitButtonTarget.innerHTML = '…';
  }

  undisableSubmit() {
    this.submitButtonTarget.disabled = false;
    this.submitButtonTarget.innerHTML = 'Subscribe';
  }

  // sendCardToStripe() {
  //   console.log('SEND CARD TO STRIPE');
  // }

  // validateCardData(e) {
  //   console.log('validateCardData');
  //   if (true) {
  //     // next step
  //   } else {
  //     // display errors and re-enable submit button
  //   }
  // }

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
