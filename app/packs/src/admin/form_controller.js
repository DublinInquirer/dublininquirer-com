import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["form"];

  connect() {}

  submitForm(event) {
    event.preventDefault();
    this.formTarget.submit();
  }
}
