import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="calendar-date-hover"
export default class extends Controller {
  static targets = ["day", "line"];

  connect() {
    this.sortedTargets = this.lineTargets.sort((a, b) => a.id - b.id);
  }

  highlight(event) {
    const id = Number(event.currentTarget.id);

    this.sortedTargets
      .filter((line) => Number(line.id) == id)
      .forEach((line) => this.#emphazise(line));

    this.sortedTargets
      .filter((line) => this.#isNeighbour(Number(line.id), id))
      .forEach((line) => this.#diminish(line));

    this.sortedTargets
      .filter(
        (line) =>
          !(Number(line.id) == id || this.#isNeighbour(Number(line.id), id)),
      )
      .forEach((line) => this.#hide(line));
  }

  #isNeighbour(lineId, id) {
    return [id - 1, id + 1].includes(lineId);
  }

  reset() {
    this.sortedTargets.forEach((element) => this.#reset(element));
  }

  #emphazise(element) {
    element.classList.add("opacity-100");

    element.classList.remove("h-0!");
    element.classList.remove("opacity-20");

    element.querySelector("#activities").classList.add("border-2!");
  }

  #diminish(element) {
    element.classList.remove("h-0!");
    element.classList.add("opacity-20");
    element.classList.remove("opacity-100");
    element.querySelector("#activities").classList.remove("border-2!");
  }

  #hide(element) {
    element.classList.add("h-0!");
  }

  #reset(element) {
    element.classList.add("opacity-100");

    element.classList.remove("h-0!");
    element.classList.remove("opacity-20");

    element.querySelector("#activities").classList.remove("border-2!");
  }
}
