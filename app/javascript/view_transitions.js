let navigating = false;
let currentTransition = null;
let skipNextFrameTransition = false;

document.addEventListener("click", (event) => {
  const link = event.target.closest("a[data-nav-index]");
  if (!link) return;

  const targetIndex = parseInt(link.dataset.navIndex);
  const currentIndex = parseInt(document.body.dataset.navIndex ?? "-1");

  if (isNaN(targetIndex) || currentIndex === -1 || targetIndex === currentIndex)
    return;

  document.documentElement.style.setProperty(
    "--slide-direction",
    targetIndex > currentIndex ? "1" : "-1",
  );
});

document.addEventListener("click", (event) => {
  if (!event.target.closest("#activities")) return;

  document.documentElement.style.setProperty("--roll-direction", "1");

  const link = event.target.closest("a[href]");
  if (!link) return;

  if (link.dataset.sameItem) skipNextFrameTransition = true;

  const targetDatetime = new URL(link.href, window.location.href).searchParams.get("datetime");
  const currentTimestamp = parseInt(document.getElementById("activities").dataset.currentTimestamp ?? "", 10);
  if (!targetDatetime || isNaN(currentTimestamp)) return;

  const targetTimestamp = Math.floor(new Date(targetDatetime).getTime() / 1000);
  if (targetTimestamp < currentTimestamp)
    document.documentElement.style.setProperty("--roll-direction", "-1");
});

document.addEventListener("turbo:visit", (event) => {
  const targetPath = new URL(event.detail.url, window.location.href).pathname;
  if (targetPath !== window.location.pathname) navigating = true;
});
document.addEventListener("turbo:load", () => {
  navigating = false;
});

document.addEventListener("turbo:before-render", (event) => {
  if (!document.startViewTransition || !navigating) return;

  navigating = false;
  event.preventDefault();

  if (currentTransition) currentTransition.skipTransition();

  currentTransition = document.startViewTransition({
    update: () => event.detail.resume(),
    types: ["page-nav"],
  });
  currentTransition.finished.finally(() => {
    currentTransition = null;
    document.documentElement.style.removeProperty("--slide-direction");
  });
});

document.addEventListener("turbo:before-frame-render", (event) => {
  if (!document.startViewTransition || event.target.id !== "activities") return;

  if (skipNextFrameTransition) {
    skipNextFrameTransition = false;
    return;
  }

  const render = event.detail.render;
  event.detail.render = (currentElement, newElement) => {
    const transition = document.startViewTransition({
      update: () => render(currentElement, newElement),
      types: ["frame-nav"],
    });
    transition.finished.finally(() => {
      document.documentElement.style.removeProperty("--roll-direction");
    });
    return transition;
  };
});

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "activities") skipNextFrameTransition = false;
});
