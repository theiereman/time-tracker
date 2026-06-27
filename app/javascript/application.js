// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

let navigating = false;
let currentTransition = null;

document.addEventListener("click", (event) => {
  const link = event.target.closest("a[data-nav-index]");
  if (!link) return;

  const targetIndex = parseInt(link.dataset.navIndex);
  const currentIndex = parseInt(document.body.dataset.navIndex ?? "-1");

  if (isNaN(targetIndex) || currentIndex === -1 || targetIndex === currentIndex) return;

  document.documentElement.style.setProperty(
    "--slide-direction",
    targetIndex > currentIndex ? "1" : "-1"
  );
});

document.addEventListener("turbo:visit", () => { navigating = true; });
document.addEventListener("turbo:load", () => { navigating = false; });

document.addEventListener("turbo:before-render", (event) => {
  if (!document.startViewTransition || !navigating) return;

  navigating = false;
  event.preventDefault();

  if (currentTransition) currentTransition.skipTransition();

  currentTransition = document.startViewTransition(() => event.detail.resume());
  currentTransition.finished.finally(() => {
    currentTransition = null;
    document.documentElement.style.removeProperty("--slide-direction");
  });
});
import "chartkick";
import "Chart.bundle";

import { init } from "@plausible-analytics/tracker";

init({
  domain: "timetracker.dotsncircles.com",
  endpoint: "https://plausible.dotsncircles.com/api/event",
});
