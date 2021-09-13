import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["form"];

  connect() {}

  submitForm(event) {
    console.log(event);
    event.preventDefault();
  }
}
