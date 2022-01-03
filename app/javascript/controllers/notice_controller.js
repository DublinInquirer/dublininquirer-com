import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notice"];

  connect() {}

  closeNotice(e) {
    e.preventDefault();
    this.noticeTarget.classList.add("-hidden");
    setTimeout(function () {
      return this.noticeTarget.detach();
    }, 1000);
  }
}
