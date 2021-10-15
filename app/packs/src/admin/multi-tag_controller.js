import { Controller } from "stimulus";
import Tagify from "@yaireo/tagify";

export default class extends Controller {
  static targets = ["tagInput"];

  connect() {
    var tagify = new Tagify(this.tagInputTarget, {
      whitelist: ["music", "society", "culture"],
      editTags: false,
      enforceWhitelist: true,
    });
  }
}
