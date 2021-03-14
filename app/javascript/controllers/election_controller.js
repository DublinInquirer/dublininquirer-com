import { Controller } from "stimulus";
import * as Turbo from "@hotwired/turbo";
import smoothscroll from "smoothscroll-polyfill";

export default class extends Controller {
  static targets = ["switcher"];

  connect() {
    smoothscroll.polyfill();
  }

  scrollTo(event) {
    event.preventDefault();

    window.scrollTo({
      top:
        document
          .querySelector(event.target.getAttribute("href"))
          .getBoundingClientRect().top + window.pageYOffset,
      behavior: "smooth",
    });
  }

  switchView(event) {
    let path =
      this.switcherTarget.getAttribute("data-election-path") +
      this.switcherTarget.value;
    event.stopImmediatePropagation();
    Turbo.visit(path);
  }
}
