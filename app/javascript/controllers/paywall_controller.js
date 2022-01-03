import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="paywall"
export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    this.openOverlay();
  }

  openOverlay() {
    let overlay = this.overlayTarget;
    overlay.classList.add("-displayed");

    setTimeout(function () {
      document.body.classList.add("-overlay-open");
      overlay.classList.add("-open");
    }, 1000);
  }
}
