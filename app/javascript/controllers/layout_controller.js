import { Controller } from "@hotwired/stimulus"
import smoothscroll from "smoothscroll-polyfill";

// Connects to data-controller="layout"

export default class extends Controller {
  static targets = ["metaNav"];

  connect() {
    smoothscroll.polyfill();
    this.maybeShowMetaNav();
  }

  openSearch(e) {
    e.preventDefault();
    this.openOverlay("search");
  }

  closeSearch(e) {
    e.preventDefault();
    this.closeOverlay("search");
  }

  openMenu(e) {
    e.preventDefault();
    this.openOverlay("menu");
  }

  closeMenu(e) {
    e.preventDefault();
    this.closeOverlay("menu");
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

  onScroll() {
    this.maybeShowMetaNav();
  }

  openOverlay(id) {
    let overlay = document.getElementById(id);

    overlay.classList.remove("-hidden");
    setTimeout(function () {
      document.body.classList.add("-overlay-open");
      overlay.classList.add("-open");
      if (id == "search") { overlay.querySelector("[name=q]").focus(); }
    }, 25);
  }

  closeOverlay(id) {
    let overlay = document.getElementById(id);

    document.body.classList.remove("-overlay-open");

    overlay.classList.remove("-open");

    setTimeout(function () {
      return overlay.classList.add("-hidden");
    }, 250);
  }

  maybeShowMetaNav() {
    if (window.pageYOffset > 155) {
      this.metaNavTarget.classList.add("-open");
    } else {
      this.metaNavTarget.classList.remove("-open");
    }
  }
}
