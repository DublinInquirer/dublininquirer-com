import Sortable from "sortablejs";
import { Controller } from "stimulus";

export default class extends Controller {
  static values = { persistUrl: String };
  static targets = ["preview", "article"];

  connect() {
    console.log(this.persistUrlValue);
    console.log(this.articleTargets);
    let controller = this;
    Sortable.create(this.previewTarget, {
      chosenClass: "-chosen",
      ghostClass: "-ghost",
      onSort: function (e) {
        controller.persistPositions();
      },
    });
  }

  persistPositions() {
    fetch(this.persistUrlValue, {
      method: "PUT",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ positions: this.orderedPositionsArray() }),
    });
  }

  orderedPositionsArray() {
    let i = 0;

    return Array.from(
      this.previewTarget.querySelectorAll(".layouter__article")
    ).map((a) => {
      i++;
      return {
        id: a.getAttribute("data-layouter-article-id"),
        position: i,
      };
    });
  }
}
