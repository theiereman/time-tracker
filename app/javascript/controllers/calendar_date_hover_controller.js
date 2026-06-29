import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="calendar-date-hover"
export default class extends Controller {
  static targets = ["day", "line"];

  connect() {
    this.sortedTargets = this.lineTargets.sort((a, b) => a.id - b.id);
  }

  highlight(event) {
    const id = event.currentTarget.id;

    this.sortedTargets
      .filter((line) => line.id == id)
      .forEach((line) => this.#emphazise(line));

    this.sortedTargets
      .filter((line) => line.id != id)
      .forEach((line) => this.#diminish(line));
  }

  reset() {
    this.sortedTargets.forEach((element) => this.#reset(element));
  }

  #emphazise(element) {
    element.classList.add("opacity-100");

    element.classList.remove("h-0!");
    element.classList.remove("opacity-20");

    element.querySelector("#activities").classList.add("border!");
  }

  #diminish(element) {
    element.classList.add("opacity-20");
    element.classList.add("h-0!");

    element.classList.remove("opacity-100");

    element.querySelector("#activities").classList.remove("border!");
  }

  #reset(element) {
    element.classList.add("opacity-100");

    element.classList.remove("h-0!");
    element.classList.remove("opacity-20");

    element.querySelector("#activities").classList.remove("border!");
  }
}
