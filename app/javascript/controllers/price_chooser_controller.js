import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="price-chooser"
export default class extends Controller {
  static targets = ['amount', 'productSlug'];

  connect() {
    this.element.action = '';
  }

  validateAmount() {
    const min = this.minimumFor(this.productSlugTarget.value);
    console.log(min);
    // TODO!
  }

  subscribe(e) {
    e.preventDefault();
    window.location.href = `/v2/subscribe/${this.productSlugTarget.value}/${this.amountTarget.value}`;
  }

  minimumFor(slug) {
    switch (slug) {
      case 'digital':
        return 6;
      case 'print':
        return 9;
    }
  }
}
