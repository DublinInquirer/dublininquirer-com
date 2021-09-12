import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["textInput"];

  connect() {}

  selectTag(e) {
    e.preventDefault();
    this.textInputTarget.value = e.target.text;
    this.closePopUpFor(this.textInputTarget);
  }

  autocomplete(e) {
    fetch(`/admin/tags/autocomplete?q=${this.textInputTarget.value}`)
      .then((response) => response.json())
      .then((json) => this.updatePopupWith(json));
  }

  updatePopupWith(json) {
    const popup = this.findOrCreatePopupFor(this.textInputTarget);
    popup.innerHTML = this.htmlForPopupWith(json);
  }

  findOrCreatePopupFor(input) {
    if (input.nextElementSibling == null) {
      this.createPopupFor(input);
    }
    return input.nextElementSibling;
  }

  createPopupFor(input) {
    const popup = document.createElement("div");
    popup.setAttribute("class", "autocomplete__popup");
    input.parentNode.appendChild(popup);
  }

  htmlForPopupWith(json) {
    let html = ``;
    for (let tag of json) {
      html = html + `<a data-action="tag#selectTag">${tag.name}</a>`;
    }

    return html;
  }

  closePopUpFor(input) {
    input.nextElementSibling.remove();
  }
}
