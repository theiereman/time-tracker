import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tooltip"
//
// Used where the tooltip's container has `overflow-hidden` (e.g. the
// calendar's collapsible rows), which clips a `position: absolute` tooltip.
// On hover we switch the text to `position: fixed` (relative to the viewport,
// so it isn't clipped) and compute its coordinates from the hovered element.
export default class extends Controller {
  show(event) {
    const tip = event.currentTarget.querySelector(".tooltiptext");
    if (!tip) return;

    const rect = event.currentTarget.getBoundingClientRect();
    tip.style.position = "fixed";
    tip.style.left = `${rect.left + rect.width / 2}px`;
    tip.style.top = `${rect.bottom + 6}px`;
    tip.classList.add("tooltiptext--visible");
  }

  hide(event) {
    const tip = event.currentTarget.querySelector(".tooltiptext");
    if (!tip) return;

    tip.classList.remove("tooltiptext--visible");
    tip.style.position = "";
    tip.style.left = "";
    tip.style.top = "";
  }
}
