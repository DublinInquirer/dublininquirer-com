import { Controller } from "stimulus";

export default class extends Controller {
  static values = { min: Number, max: Number };
  static targets = ["input", "hint"];

  connect() {
    this.updateHint();
  }

  updateHint() {
    let currentCount = this.inputTarget.value.length;
    this.hintTarget.innerHTML = `${currentCount} characters – excerpt should be between ${this.minValue} and ${this.maxValue}`;
  }
}
