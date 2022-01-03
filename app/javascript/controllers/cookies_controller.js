import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cookies"
export default class extends Controller {
  static targets = ["notice"];
  connect() {
  }

  closeNotice() {
    this.noticeTarget.classList.add("-hidden");
    this.noticeTarget.remove(); // todo animate this
  }

  acceptCookies() {
    this.closeNotice();
  }
}