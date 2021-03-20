import Rails from "@rails/ujs";
import * as Turbo from "@hotwired/turbo";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const images = require.context("../images", true);
const imagePath = (name) => images(name, true);

Rails.start();

const application = Application.start();
const context = require.context("../controllers/admin", true, /\.js$/);
application.load(definitionsFromContext(context));
