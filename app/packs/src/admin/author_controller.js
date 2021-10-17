import { Controller } from "stimulus";
import Tagify from "@yaireo/tagify";

export default class extends Controller {
  static values = { authors: Array };
  static targets = ["authorInput"];

  connect() {
    console.log(this.authorsValue);
    var tagify = new Tagify(this.authorInputTarget, {
      whitelist: ["music", "society", "culture"],
      editTags: false,
      enforceWhitelist: true,
    });
  }
}
