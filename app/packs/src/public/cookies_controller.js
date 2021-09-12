import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["notice"];

  connect() {}

  closeNotice() {
    this.noticeTarget.classList.add("-hidden");
    setTimeout(function () {
      return this.noticeTarget.detach();
    }, 1000);
  }

  acceptCookies() {
    this.closeNotice();
  }
}
