import { Controller } from "stimulus";
import Tagify from "@yaireo/tagify";

export default class extends Controller {
  static values = { authors: Array };
  static targets = ["authorInput"];

  connect() {
    // TODO figure out how to persist IDs
    const authorNames = this.authorsValue.map(authorItem => authorItem[0]);
    var tagify = new Tagify(this.authorInputTarget, {
      whitelist: authorNames,
      editTags: false,
      enforceWhitelist: true,
    });
  }
}
