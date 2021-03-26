import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["form", "select"];

  connect() {
    for (let select of this.selectTargets) {
      switch (select.getAttribute("data-form-id")) {
        case "tag":
          this.initializeTagSelect(select);
          break;
      }
    }
  }

  submitForm(e) {
    e.preventDefault();
    this.formTarget.submit();
  }

  initializeTagSelect(select) {
    new SlimSelect({
      select: select,
      placeholder: "Enter tag",
      ajax: function (search, callback) {
        // Check search value. If you dont like it callback(false) or callback('Message String')
        if (search.length < 3) {
          callback("Need 3 characters");
          return;
        }

        // Perform your own ajax request here
        fetch("/admin/tags/autocomplete")
          .then(function (response) {
            return response.json();
          })
          .then(function (json) {
            let data = [];
            for (let i = 0; i < json.length; i++) {
              data.push({ text: json[i].name });
            }

            // Upon successful fetch send data to callback function.
            // Be sure to send data back in the proper format.
            // Refer to the method setData for examples of proper format.
            callback(data);
          })
          .catch(function (error) {
            // If any erros happened send false back through the callback
            callback(false);
          });
      },
    });
  }
}
