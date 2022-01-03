import Plyr from 'plyr';
import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="player"
export default class extends Controller {
  connect() {
    const player = new Plyr(this.element.querySelector('audio'), {
      controls: ['play', 'progress', 'current-time', 'mute', 'volume']
    });
  }
}