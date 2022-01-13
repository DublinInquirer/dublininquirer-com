import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="price-chooser"
export default class extends Controller {
  static targets = ['amount', 'productSlug', 'subscribeButton'];

  connect() {
    this.element.action = '';
  }

  validateAmount() {
    this.amountTarget.value = parseInt(this.amountTarget.value);
    if (this.amountTarget.value < this.minimumFor(this.productSlugTarget.value)) {
      this.addError();
    } else {
      this.removeError();
    }
  }

  addError() {
    this.amountTarget.parentNode.parentNode.classList.add('-error');
    this.amountTarget.parentNode.parentNode.querySelector(
      '.hint',
    ).innerHTML = `Minimum €${this.minimumFor(this.productSlugTarget.value)}/month`;
  }

  removeError() {
    this.amountTarget.parentNode.parentNode.classList.remove('-error');
    this.amountTarget.parentNode.parentNode.querySelector('.hint').innerHTML = 'per month';
  }

  subscribe(e) {
    this.disableSubmit();
    e.preventDefault();
    if (this.anyErrors()) {
      this.undisableSubmit();
      this.shake();
    } else {
      window.location.href = `/v2/subscribe/${this.productSlugTarget.value}/${this.amountTarget.value}`;
    }
  }

  change(e) {
    this.disableSubmit();
    e.preventDefault();
    if (this.anyErrors()) {
      this.undisableSubmit();
      this.shake();
    } else {
      window.location.href = `/user/subscription/${this.productSlugTarget.value}/${this.amountTarget.value}`;
    }
  }

  minimumFor(slug) {
    switch (slug) {
      case 'digital':
        return 6;
      case 'print':
        return 9;
    }
  }

  anyErrors() {
    return this.amountTarget.parentNode.parentNode.classList.contains('-error');
  }

  shake() {
    this.amountTarget.parentNode.parentNode.style.animation = 'none';
    window.requestAnimationFrame(() => {
      this.amountTarget.parentNode.parentNode.style.animation =
        'shake 0.76s cubic-bezier(0.36, 0.07, 0.19, 0.97) both';
    });
  }

  disableSubmit() {
    this.subscribeButtonTarget.disabled = true;
  }
  undisableSubmit() {
    this.subscribeButtonTarget.disabled = false;
  }
}
